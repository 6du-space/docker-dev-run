#!/usr/bin/env bash

ID=$1
HOSTNAME=user-$2

let "IP=100+ID"
let "SSH_PORT=1000*ID"
let "PORT_BEGIN=SSH_PORT+1"
let "PORT_END=SSH_PORT+999"

PORT_RANGE=$PORT_BEGIN-$PORT_END

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
-v /tmp/docker/$NAME:/tmp \
-v /mnt/share:/mnt/share \
-h $HOSTNAME \
--name $NAME \
--net $NET \
--ip $SUBNET.$IP \
--device /dev/fuse \
--cap-add SYS_ADMIN \
--restart=always $IMAGE

mkdir -p $DOCKER_ROOT/root/.ssh
chmod 700 $DOCKER_ROOT/root/.ssh
cp ~/.ssh/authorized_keys $DOCKER_ROOT/root/.ssh

