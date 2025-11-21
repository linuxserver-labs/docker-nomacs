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
    libgtest-dev \
    libheif-dev \
    libopencv-dev \
    libqt6svg6-dev \
    libquazip1-qt6-dev \
    libraw-dev \
    libtiff-dev \
    libwebp-dev \
    libxkbcommon-dev \
    libzip-dev \
    qmake6 \
    qt6-declarative-dev-tools \
    qt6-svg-dev \
    qt6-tools-dev && \
  echo "**** install runtime dependencies ****" && \
  apt-get install -y --no-install-recommends \
    kimageformat-plugins \
    libexiv2-27 \
    libheif1 \
    libopencv-core406t64 \
    libopencv-imgproc406t64 \
    libquazip1-qt6-1t64 \
    libqt6concurrent6t64 \
    libqt6printsupport6t64 \
    libqt6svg6 \
    libraw23t64 \
    qt6-image-formats-plugins && \
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
  cmake \
    -DENABLE_OPENCV=ON \
    -DENABLE_RAW=ON \
    -DENABLE_TIFF=ON \
    -DENABLE_QUAZIP=ON \
    -DENABLE_PLUGINS=ON \
    ../ImageLounge/. && \
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
    libgtest-dev \
    libheif-dev \
    libopencv-dev \
    libqt6svg6-dev \
    libquazip1-qt6-dev \
    libquazip5-dev \
    libraw-dev \
    libtiff-dev \
    libwebp-dev \
    libxkbcommon-dev \
    libzip-dev \
    qmake6 \
    qt6-declarative-dev-tools \
    qt6-svg-dev \
    qt6-tools-dev && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /
