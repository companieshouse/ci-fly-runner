FROM amazonlinux:2

ARG fly_version=7.9.1
ARG platform_tools_common_version=1.0.6
ARG yq_version=4.43.1
ARG yq_binary="yq_linux_amd64"

RUN yum update -y && \
    yum -y install \
    git \
    gzip \
    tar && \
    yum clean all

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

RUN curl -Ls "https://github.com/mikefarah/yq/releases/download/v${yq_version}/${yq_binary}.tar.gz" | \
    tar -zx && \
    mv "${yq_binary}" "/usr/local/bin/yq" && \
    rm -f ./*

RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    yum install -y platform-tools-common-${platform_tools_common_version} && \
    yum clean all

COPY resources/ /usr/local/bin/
