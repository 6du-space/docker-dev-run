#!/usr/bin/env bash

sudo systemctl enable docker.service

# fix wrong driver
echo '{ "storage-driver": "devicemapper" }' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker.service

# fix aliyun buggy selinux
sudo sed -i 's/SELINUXTYPE=mcs/SELINUXTYPE=targeted/' /etc/selinux/config

