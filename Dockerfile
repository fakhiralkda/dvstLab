FROM debian:bullseye-slim as base

ENV DEBIAN_FRONTEND="noninteractive" MEGA_SDK_VERSION="3.9.5"

RUN echo "deb http://http.us.debian.org/debian/ testing non-free contrib main" >> /etc/apt/sources.list && \
    apt -qqy update \
    && apt install -qqy --no-install-recommends aria2 curl \
    qbittorrent-nox tzdata p7zip-full p7zip-rar xz-utils \
    pv jq ffmpeg locales unzip neofetch \
    libmagic-dev libfreeimage-dev libcrypto++-dev \
    && apt -qqy autoclean \
    && rm -rf /var/lib/apt/lists/*


FROM base as builder

RUN apt -qqy update \
    && apt install -qqy --no-install-recommends \
    python3 python3-pip python3-lxml make g++ gcc \
    automake autoconf libtool libcurl4-openssl-dev \
    qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
    git libsodium-dev libssl-dev libc-ares-dev \
    libsqlite3-dev swig libboost-all-dev \
    libpthread-stubs0-dev zlib1g-dev libpq-dev libffi-dev \
    && apt -qqy autoclean \
    && rm -rf /var/lib/apt/lists/*

# Compile Mega SDK Python Binding
RUN git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION mega-sdk \
    && cd mega-sdk && rm -rf .git \
    && autoupdate -fIv && ./autogen.sh \
    && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel


FROM base

COPY --from=builder /mega-sdk/bindings/python/dist/me* /mega-sdk/bindings/python/dist/
COPY --from=builder /mega-sdk/src/.libs/ /mega-sdk/src/.libs/

RUN pip3 install /mega-sdk/bindings/python/dist/megasdk-$MEGA_SDK_VERSION-*.whl \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8