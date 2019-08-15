FROM alpine:3.10

RUN apk update

RUN apk add bash=5.0.0-r0

RUN apk add curl=7.65.1-r0

RUN wget https://github.com/concourse/concourse/releases/download/v4.2.1/fly_linux_amd64 -O /usr/bin/fly \
    && chmod +x /usr/bin/fly
