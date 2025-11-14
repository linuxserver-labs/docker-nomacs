# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

ARG BUILD_DATE
ARG VERSION
ARG APP_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  DEBIAN_FRONTEND="noninteractive" \
  HOME=/config \
  TITLE="nomacs"

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/nomacs-logo.png && \
  echo "**** install build dependencies ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    cdbs \
    cmake \
    debhelper \
    git \
    lcov \
    libexiv2-dev \
    libheif-dev \
    libopencv-dev \
    libqt5svg5-dev \
    libquazip5-dev \
    libraw-dev \
    libtiff-dev \
    libwebp-dev \
    libzip-dev \
    qt5-qmake \
    qttools5-dev \
    qttools5-dev-tools && \
  echo "**** install runtime dependencies ****" && \
  apt-get install -y --no-install-recommends \
    kimageformat-plugins \
    libexiv2-27 \
    libheif1 \
    libopencv-core406t64 \
    libopencv-imgproc406t64 \
    libquazip5-1t64 \
    libqt5concurrent5t64 \
    libqt5printsupport5t64 \
    libqt5svg5 \
    libraw23t64 \
    qt5-image-formats-plugins && \
  echo "**** compile heif plugin ****" && \
  mkdir -p /tmp/heif && \
  git clone https://github.com/jakar/qt-heif-image-plugin.git /tmp/heif && \
  mkdir -p /tmp/heif/build && \
  cd /tmp/heif/build && \
  cmake .. && \
  make && \
  make install && \
  echo "**** compile nomacs ****" && \
  if [ -z "${APP_VERSION}" ]; then \
    APP_VERSION=$(curl -sX GET https://api.github.com/repos/nomacs/nomacs/commits/master | jq -r '. | .sha' | cut -c1-8); \
  fi && \
  mkdir -p /tmp/nomacs && \
  git clone --recurse-submodules https://github.com/nomacs/nomacs.git /tmp/nomacs && \
  cd /tmp/nomacs && \
  git checkout "${APP_VERSION}" && \
  mkdir -p /tmp/nomacs/build && \
  cd /tmp/nomacs/build && \
  cmake ../ImageLounge/. && \
  make && \
  make install && \
  ldconfig && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** clean up ****" && \
  apt-get purge --auto-remove -y \
    build-essential \
    cdbs \
    cmake \
    debhelper \
    git \
    lcov \
    libexiv2-dev \
    libheif-dev \
    libopencv-dev \
    libqt5svg5-dev \
    libquazip5-dev \
    libraw-dev \
    libtiff-dev \
    libwebp-dev \
    libzip-dev \
    qt5-qmake \
    qttools5-dev \
    qttools5-dev-tools && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /
