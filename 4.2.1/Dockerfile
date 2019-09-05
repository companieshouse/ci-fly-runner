# Build Stage
FROM alpine:3.10

RUN apk update \
    && apk upgrade --no-cache
RUN apk add --no-cache bash=5.0.0-r0

ADD https://github.com/concourse/concourse/releases/download/v4.2.1/fly_linux_amd64 /usr/bin/fly

RUN chmod +x /usr/bin/fly
