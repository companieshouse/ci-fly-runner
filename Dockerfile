FROM alpine:3.10

RUN apk add bash curl

RUN wget https://github.com/concourse/concourse/releases/download/v4.2.1/fly_linux_amd64 -O /usr/bin/fly \
    && chmod +x /usr/bin/fly
