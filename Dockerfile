FROM amazonlinux:2

ARG CONCOURSE_VERSION=6.7.1

RUN yum update -y && \
    yum -y install \
    curl \
    git \
    tar && \
    yum clean all

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -L https://github.com/concourse/concourse/releases/download/v${CONCOURSE_VERSION}/fly-${CONCOURSE_VERSION}-linux-amd64.tgz \
    | tar -pzxv -C /usr/bin && \
    rm -f /tmp/fly.tgz

COPY resources/validate-pipelines /usr/local/bin/validate-pipelines
COPY resources/log-output /usr/local/bin/log-output
