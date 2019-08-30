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
RUN # Concourse-Pipeline-Inserts-Code-Here \
    && echo Fly version: $flyversion \
    && if  [ "${flyversion:0:1}" -gt 4 ]; then flybinary=fly-${flyversion}-linux-amd64.tgz; else flybinary=fly_linux_amd64; fi \
    && echo Fly binary to download: $flybinary \
    && wget https://github.com/concourse/concourse/releases/download/v${flyversion}/${flybinary} -O /usr/bin/fly \
    && if  [ "${flyversion:0:1}" -gt 4 ]; then tar zxvf /usr/bin/fly -C /usr/bin; fi \
    && chmod +x /usr/bin/fly


# Test Stage
FROM build AS test
ARG flyversion
RUN # Concourse-Pipeline-Inserts-Code-Here \
    && fly --version | grep ${flyversion}


# Final Stage
FROM build
