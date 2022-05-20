#  Copyright (C) 2021 Intel Corporation
#  SPDX-License-Identifier: BSD-3-Clause

FROM ubuntu:focal

# Containerized build environment for iSecL-DC product

# Metadata
LABEL org.opencontainers.image.url=https://github.com/intel-secl/intel-secl
LABEL org.opencontainers.image.documentation=https://github.com/intel-secl/docs
LABEL org.opencontainers.image.source=https://github.com/intel-secl/build-manifest
LABEL org.opencontainers.image.version=v1.0.0
LABEL org.opencontainers.image.vendor="Intel Corporation"
LABEL org.opencontainers.image.license="BSD-3-Clause"

# Build Args
ARG http_proxy
ARG https_proxy
ARG no_proxy
ARG GO_VERSION=1.16.7
ARG ISECLRELEASEBRANCH=refs/tags/v4.1.2
ARG EXT_USER
ARG REGISTRY_MIRROR_URL

# Bake these settings in for rebuild
ENV ISECLRELEASEBRANCH=${ISECLRELEASEBRANCH}
ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV no_proxy=${no_proxy}
ENV GOPATH=/go/
ENV EXT_USER=${EXT_USER}

# 1 - Load entrypoint
WORKDIR /
COPY builder/build.sh /
RUN chmod +x /build.sh
COPY manifest /build-manifest/manifest
COPY .git /build-manifest/.git

# 2 - Pre-requisites which are not handled by install scripts
RUN apt-get update -y && apt-get install -y git build-essential wget python3 sudo libtss2-esys0 libprotobuf-dev libssl-dev  perl makeself && \
    # Protobuf is required for SGX deps
    ln -sf /usr/bin/python3 /usr/bin/python && ln -sf /usr/bin/pip3 /usr/bin/pip && \
    git clone https://gerrit.googlesource.com/git-repo && install -m 755 git-repo/repo /usr/local/bin && rm -rf git-repo && \
    # 3 - Golang \
    echo "Installing golang" && wget -q "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" && tar -xzf "go${GO_VERSION}.linux-amd64.tar.gz" && \
    mv go /usr/local && rm -rf "go${GO_VERSION}.linux-amd64.tar.gz" && ln -sf /usr/local/go/bin/* /usr/local/bin/ && go version && \
    # 4 - Prereqs \
    echo "Install & Configure pre-reqs for build" && \
    # 5 - Source FS manifest only to install pre-reqs from utils repo
    git config --global user.name "ISecl Builder" && \
    git config --global user.email "isecl.builder@example.org" && \
    git config --global color.ui false && \
    # 6 - Install Swagger Prereqs
    echo "Install pre-reqs for swagger-docs" && \
    wget -q https://github.com/go-swagger/go-swagger/releases/download/v0.21.0/swagger_linux_amd64 -O /usr/local/bin/swagger && \
    chmod +x /usr/local/bin/swagger && \
    wget -q https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.16/swagger-codegen-cli-3.0.16.jar -O /usr/local/bin/swagger-codegen-cli.jar && \
    # 7 - Preload build pre-reqs from utils
    echo "Pre-load build-reqs" && mkdir -p /work/ && cd /work && repo init -u /build-manifest/  -b "$ISECLRELEASEBRANCH"  -m manifest/all-components.xml && repo sync --force-sync && /build.sh prereq && \
    # 8 - Cleanup apt cache
    apt-get clean && apt-get autoclean
ENV _CONTAINERS_USERNS_CONFIGURED=""

ENTRYPOINT [ "/build.sh" ]
