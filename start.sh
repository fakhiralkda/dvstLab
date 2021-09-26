#!/bin/bash

apt remove -qqy docker docker-engine docker.io containerd runc
apt update -qqy
apt install -qqy apt-transport-https ca-certificates curl gnupg lsb-release wget

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -qqy
apt install -qqy docker-ce docker-ce-cli containerd.io

mkdir build && cd build
wget https://raw.githubusercontent.com/fakhiralkda/dvstLab/master/Dockerfile

if docker build . -t rzlamrr/megasdk:bullseye-slim; then
    docker logout
    echo "$PW" | docker login -u rzlamrr --password-stdin
    docker push rzlamrr/megasdk:bullseye-slim
    docker logout
else
    echo
    echo "Failed!!"
fi
