# syntax=docker/dockerfile:1
ARG OS_TYPE=ubuntu
ARG OS_VERSION=22.04
FROM ${OS_TYPE}:${OS_VERSION}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    curl tzdata build-essential git libcairo2-dev

ARG GO_VERSION=1.23.3
RUN curl -sSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar zxf - -C /usr/local/

ARG SRC_DIR=/src
ARG BUILD_USER=build
RUN useradd -m -d ${SRC_DIR} -s /bin/bash ${BUILD_USER}

ARG NFPM_VERSION=2.41.1
WORKDIR ${SRC_DIR}
RUN git clone https://github.com/goreleaser/nfpm
WORKDIR ${SRC_DIR}/nfpm
RUN git checkout v${NFPM_VERSION}
RUN /usr/local/go/bin/go build -o /usr/local/bin/nfpm ./cmd/nfpm

COPY --chown=${BUILD_USER}:${BUILD_USER} ./carbonapi/ nfpm.yaml.in carbonapi.service /src/carbonapi/
USER ${BUILD_USER}
WORKDIR ${SRC_DIR}/carbonapi
RUN make GO=/usr/local/go/bin/go
RUN make install DESTDIR=./dest
ARG PKG_VERSION
ARG PKG_RELEASE
RUN sed "s/@PKG_VERSION@/${PKG_VERSION}/;s/@PKG_RELEASE@/${PKG_RELEASE}/" nfpm.yaml.in > nfpm.yaml
RUN nfpm pkg --packager deb --target /src/

USER root
