#!/usr/bin/env bash

_dirname=$(realpath $(cd "$(dirname "$0")"; pwd))

cd $_dirname
cd /etc/supervisor/conf.d
ln -s $_dirname/supervisor/*.conf .
sudo supervisorctl reload
