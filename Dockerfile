FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

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
    libopencv-core4.5d \
    libopencv-imgproc4.5d \
    libquazip5-1 \
    libqt5concurrent5 \
    libqt5printsupport5 \
    libqt5svg5 \
    libraw20 \
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
