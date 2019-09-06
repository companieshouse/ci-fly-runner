FROM alpine:3.10

ADD https://github.com/concourse/concourse/releases/download/v5.4.1/fly-5.4.1-linux-amd64.tgz /tmp/fly.tgz

RUN tar zxvf /tmp/fly.tgz -C /usr/bin \
    && rm -f /tmp/fly.tgz \
    && chmod +x /usr/bin/fly
