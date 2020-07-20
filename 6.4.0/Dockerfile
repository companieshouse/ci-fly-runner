FROM alpine:3.10

RUN apk update \
    && apk upgrade --no-cache
RUN apk add --no-cache bash=5.0.0-r0
RUN apk add --no-cache curl=7.66.0-r0

RUN curl -L https://github.com/concourse/concourse/releases/download/v6.4.0/fly-6.4.0-linux-amd64.tgz \
    | tar -pzxv -C /usr/bin

RUN rm -f /tmp/fly.tgz 
