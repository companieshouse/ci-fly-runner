FROM 416670754337.dkr.ecr.eu-west-2.amazonaws.com/ci-core-runtime:1.2.0

ARG fly_version=8.2.4
ARG yq_version=4.53.3
ARG yq_binary="yq_linux_amd64"

RUN dnf update -y && \
    dnf -y install \
    git-2.50.1 \
    gzip-1.12 \
    python3.13-3.13.14 \
    python3.13-pip-24.2 \
    tar-1.34 && \
    dnf clean all

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /tmp

RUN curl -Ls "https://github.com/concourse/concourse/releases/download/v${fly_version}/fly-${fly_version}-linux-amd64.tgz" \
        -o "fly-${fly_version}-linux-amd64.tgz" && \
    curl -Ls "https://github.com/concourse/concourse/releases/download/v${fly_version}/fly-${fly_version}-linux-amd64.tgz.sha1" \
        -o "fly-${fly_version}-linux-amd64.tgz.sha1" && \
    sha1sum --status -c "fly-${fly_version}-linux-amd64.tgz.sha1" && \
    tar -zxf "fly-${fly_version}-linux-amd64.tgz" && \
    mv "fly" "/usr/local/bin/fly-${fly_version}" && \
    rm -f ./*

RUN curl -Ls "https://github.com/mikefarah/yq/releases/download/v${yq_version}/${yq_binary}.tar.gz" \
        -o "${yq_binary}.tar.gz" && \
    curl -Ls "https://github.com/mikefarah/yq/releases/download/v${yq_version}/checksums-bsd" \
        -o "checksums-bsd" && \
    sha256sum -c "checksums-bsd" --ignore-missing --status && \
    tar -zxf "${yq_binary}.tar.gz" && \
    mv "${yq_binary}" "/usr/local/bin/yq" && \
    rm -f ./*

COPY resources/ /usr/local/bin/

COPY /packages/ /packages/
RUN dnf -y install --disablerepo=* /packages/*.rpm && \
    dnf clean all && \
    python3.13 -m pip --no-cache-dir install /packages/*.whl && \
    rm -rf /packages/
