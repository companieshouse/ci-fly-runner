FROM alpine:3.10

RUN apk update \
    && apk upgrade --no-cache
RUN apk add --no-cache bash=5.0.0-r0
RUN apk add --no-cache curl=7.65.1-r0

ADD https://github.com/concourse/concourse/releases/download/v5.4.1/fly-5.4.1-linux-amd64.tgz /tmp/fly.tgz

RUN tar zxvf /tmp/fly.tgz -C /usr/bin \
    && rm -f /tmp/fly.tgz \
    && chmod +x /usr/bin/fly
