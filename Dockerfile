FROM alpine:3.16

ARG CONCOURSE_VERSION=6.7.1

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    bash=5.1.16-r2 \
    curl=7.83.1-r3 \
    git=2.36.2-r0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -L https://github.com/concourse/concourse/releases/download/v${CONCOURSE_VERSION}/fly-${CONCOURSE_VERSION}-linux-amd64.tgz \
    | tar -pzxv -C /usr/bin && \
    rm -f /tmp/fly.tgz

COPY resources/validate-pipelines /usr/local/bin/validate-pipelines
COPY resources/log-output /usr/local/bin/log-output
