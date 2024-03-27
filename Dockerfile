FROM amazonlinux:2

ARG YQ_VERSION=4.43.1
ARG YQ_BINARY="yq_linux_amd64"

RUN yum update -y && \
    yum -y install \
    gzip \
    tar && \
    yum clean all

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/${YQ_BINARY}.tar.gz | \
    tar -pzx && \
    mv ${YQ_BINARY} /usr/local/bin/yq

COPY resources/ /usr/local/bin/
