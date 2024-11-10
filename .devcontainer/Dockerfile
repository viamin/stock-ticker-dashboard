ARG RUBY_VERSION=2.7.4
FROM --platform=linux/arm64/v8 docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Add build dependencies and Node.js repository
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    ca-certificates \
    avr-libc \
    avrdude \
    build-essential \
    gcc-avr \
    git \
    libsqlite3-dev \
    nodejs \
    openssh-client \
    pkg-config \
    yarn \
    && curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh \
    && arduino-cli core update-index \
    && arduino-cli core install arduino:avr \
    && rm -rf /var/lib/apt/lists/*
