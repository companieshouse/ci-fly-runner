#!/bin/bash

echo Installing Fly version: $fly_version

if  [[ ${fly_version:0:1} -gt 4 ]]
then
  fly_binary=fly-${fly_version}-linux-amd64.tgz
else
  fly_binary=fly_linux_amd64
fi

echo Fly binary to download: $fly_binary

wget "https://github.com/concourse/concourse/releases/download/v${fly_version}/${fly_binary}" -O /usr/bin/fly

if  [[ ${fly_version:0:1} -gt 4 ]]
then
  tar zxvf /usr/bin/fly -C /usr/bin
fi

chmod +x /usr/bin/fly
