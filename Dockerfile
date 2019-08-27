#
# ci-fli-runner
#
# Set ${flyversion} on build with "--build-arg flyversion=...."
#   e.g. --build-arg flyversion=4.2.1


# Build Stage
FROM alpine:3.10 AS build

RUN apk update
RUN apk add bash=5.0.0-r0
RUN apk add curl=7.65.1-r0

ARG flyversion
RUN wget https://github.com/concourse/concourse/releases/download/v${flyversion}/fly_linux_amd64 -O /usr/bin/fly \
    && chmod +x /usr/bin/fly


# Test Stage
FROM build AS test
ARG flyversion
RUN fly --version | grep ${flyversion}


# Final Stage
FROM build
