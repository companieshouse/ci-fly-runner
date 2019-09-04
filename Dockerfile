# Build Stage
FROM alpine:3.10 AS build

COPY scripts/fly-install.sh /tmp/fly-install.sh

RUN apk update \
    && apk upgrade --no-cache
RUN apk add --no-cache bash=5.0.0-r0
RUN apk add --no-cache curl=7.65.1-r0

ARG flyversion
RUN /tmp/fly-install.sh


# Test Stage
FROM build AS test

COPY scripts/fly-test.sh /tmp/fly-test.sh

ARG flyversion
RUN /tmp/fly-test.sh


# Final Stage
FROM build
