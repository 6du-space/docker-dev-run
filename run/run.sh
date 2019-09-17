#!/usr/bin/env bash

_dirname=$(realpath $(cd "$(dirname "$0")"; pwd))

cd $_dirname

ID=$1
HOSTNAME=user-$2

let "IP=100+ID"
let "SSH_PORT=6000+ID"
let "PORT_BEGIN=10000+1000*ID"
let "PORT_END=PORT_BEGIN+999"

PORT_RANGE=$PORT_BEGIN-$PORT_END

echo $PORT_RANGE
NET=6du
SUBNET=172.20.0
VPS_IP=$SUBNET.1
IMAGE=daocloud.io/6dus/6du-dev
#IMAGE=dev:latest
NAME=$HOSTNAME

DOCKER_ROOT=/mnt/docker/$NAME

sudo docker network create --subnet=$SUBNET.0/16 $NET
sudo docker rm $NAME
sudo docker run \
-d \
--add-host=vps:$VPS_IP \
-p $PORT_RANGE:$PORT_RANGE \
-p $SSH_PORT:22 \
-v /var/log/docker/$NAME:/var/log \
-v $DOCKER_ROOT/etc/supervisor/conf.d:/etc/supervisor/conf.d \
-v $DOCKER_ROOT/etc/caddy:/etc/caddy \
-v $DOCKER_ROOT/home:/home \
-v $DOCKER_ROOT/root:/root \
-v $_dirname/sh:/root/sh \
-v /tmp/docker/$NAME:/tmp \
-v /mnt/share:/mnt/share \
-h $HOSTNAME \
--name $NAME \
--net $NET \
--ip $SUBNET.$IP \
--device /dev/fuse \
--cap-add SYS_ADMIN \
--cap-add NET_ADMIN \
--device=/dev/net/tun:/dev/net/tun \
--restart=always $IMAGE

mkdir -p $DOCKER_ROOT/root/.ssh
chmod 700 $DOCKER_ROOT/root/.ssh
cp ~/.ssh/authorized_keys $DOCKER_ROOT/root/.ssh
chmod 600 $DOCKER_ROOT/root/.ssh/authorized_keys

