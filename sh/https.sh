#!/usr/bin/env bash

HOST=$1

source  ~/.config/alidns.acme.sh

_dir=$(cd "$(dirname "$0")"; pwd)
cd $_dir

acme=$HOME/.acme.sh/acme.sh

if [ ! -x "$acme" ]; then
curl https://get.acme.sh | sh
fi

# export BRANCH=dev
# $acme --upgrade

if [ -f "$HOME/.acme.sh/$HOST/fullchain.cer" ]; then
echo "更新 $HOST"
$acme --use-wget --force --renew -d $HOST -d *.$HOST --log --reloadcmd "supervisorctl restart caddy"
else
echo "创建 $HOST"
$acme --use-wget --issue --dns dns_ali -d $HOST -d *.$HOST --force --log --reloadcmd "supervisorctl restart caddy"
chgrp www  ~/.acme.sh/ -R
chmod g+rx ~/.acme.sh/
chmod g+rx ~/.acme.sh/$HOST
chmod g+r ~/.acme.sh/$HOST/*
fi

