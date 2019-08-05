#!/usr/bin/env bash
SSH_PORT=1000
let "PORT_BEGIN=SSH_PORT+1"
let "PORT_END=SSH_PORT+999"
PORT_RANGE=$PORT_BEGIN-$PORT_END

HOSTNAME=dev
NET=6du
IP=100
SUBNET=172.20.0
VPS_IP=$SUBNET.1
IMAGE=daocloud.io/6dus/6du-dev
#IMAGE=dev:latest
NAME=$HOSTNAME

sudo docker network create --subnet=$SUBNET.0/16 $NET
sudo docker rm $NAME
sudo docker run \
-d \
--add-host=vps:$VPS_IP \
-p $PORT_RANGE:$PORT_RANGE \
-p $SSH_PORT:22 \
-p 80:80 \
-p 443:443 \
-v /var/log/docker/$NAME:/var/log \
-v /mnt/docker/$NAME/home:/home \
-v /mnt/docker/$NAME/root:/root \
-v /tmp/docker/$NAME:/tmp \
-v /mnt/share:/mnt/share \
-h $HOSTNAME \
--name $NAME \
--net $NET \
--ip $SUBNET.$IP \
--device /dev/fuse \
--cap-add SYS_ADMIN \
--restart=always $IMAGE
