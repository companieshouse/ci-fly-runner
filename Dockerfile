# Use amazonlinux:2 as the base image
FROM amazonlinux:2

ARG CONCOURSE_VERSION=6.7.1
# Install Python 3.8 from Software Collections (SCL) repository
RUN amazon-linux-extras enable python3.8 && \
    yum -y update  && \
    yum -y install python38 git gzip tar && \
    yum clean all

RUN curl -L https://github.com/concourse/concourse/releases/download/v${CONCOURSE_VERSION}/fly-${CONCOURSE_VERSION}-linux-amd64.tgz \
    | tar -pzxv -C /usr/bin && \
    rm -f /tmp/fly.t

RUN python3.8 -m pip install pyyaml gitpython

ENV PIPELINE_GIT_REPOSITORY="/source-code"

# Set the working directory inside the container
WORKDIR /app

# Copy the Python script to the working directory
COPY resources/pipeline_automation.py /app/

# Run the Python script when the container starts
CMD ["python3.8", "pipeline_automation.py"]