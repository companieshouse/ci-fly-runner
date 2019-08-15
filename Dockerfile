#
# ci-fli-runner
#

# Apline 3.1 image.
# https://hub.docker.com/_/alpine
FROM alpine:3.10

# Update package list.
RUN apk update

# Add bash package and dependencies.
RUN apk add bash=5.0.0-r0

# Add curl package and dependencies.
RUN apk add curl=7.65.1-r0

# Download Concourse Fly 4.2.1 and set file permissions.
RUN wget https://github.com/concourse/concourse/releases/download/v4.2.1/fly_linux_amd64 -O /usr/bin/fly \
    && chmod +x /usr/bin/fly
