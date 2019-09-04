# Build Stage
FROM alpine:3.10 AS build

COPY scripts/fly-install /tmp/fly-install

RUN apk update \
    && apk upgrade --no-cache
RUN apk add --no-cache bash=5.0.0-r0
RUN apk add --no-cache curl=7.65.1-r0

ARG fly_version
RUN /tmp/fly-install


# Test Stage
FROM build AS test

COPY scripts/fly-test /tmp/fly-test

ARG fly_version
RUN /tmp/fly-test


# Final Stage
FROM build
