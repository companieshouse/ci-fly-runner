# Build Stage
FROM alpine:3.10

COPY scripts/fly-install /tmp/fly-install

RUN apk update \
    && apk upgrade --no-cache
RUN apk add --no-cache bash=5.0.0-r0
RUN apk add --no-cache curl=7.65.1-r0

ARG fly_version
RUN /tmp/fly-install
