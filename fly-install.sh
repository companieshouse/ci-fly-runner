#!/bin/sh

echo Installing Fly version: $flyversion

if  [ "${flyversion:0:1}" -gt 4 ]
then
  flybinary=fly-${flyversion}-linux-amd64.tgz
else
  flybinary=fly_linux_amd64
fi

echo Fly binary to download: $flybinary

wget https://github.com/concourse/concourse/releases/download/v${flyversion}/${flybinary} -O /usr/bin/fly

if  [ "${flyversion:0:1}" -gt 4 ]
then
  tar zxvf /usr/bin/fly -C /usr/bin
fi

chmod +x /usr/bin/fly
