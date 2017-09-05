FROM ubuntu:17.04

WORKDIR /usr/src/elm-slides

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=C.UTF-8

RUN apt-get update -q \
  && apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" \
  && apt-get install -y --no-install-recommends \
    apt-transport-https \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    git \
    libpng-dev \
    libtool \
    nasm \
    pkg-config \
    python \
    software-properties-common \
    wget \
  && apt-get clean \
  && rm -rf /var/apt/lists

RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && echo "deb https://deb.nodesource.com/node_8.x zesty main" > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    nodejs \
  && apt-get clean \
  && rm -rf /var/apt/lists \
  && npm install --global npm node-gyp delegates
