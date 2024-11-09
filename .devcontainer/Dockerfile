ARG RUBY_VERSION=2.7.4
FROM --platform=linux/arm64/v8 docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Add build dependencies and Node.js repository
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libsqlite3-dev \
    git \
    pkg-config \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y nodejs \
    yarn \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*
