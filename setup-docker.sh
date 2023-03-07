#!/bin/bash

echo "*** Adding docker repository ..."
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "*** Install docker ..."
sudo dnf install -y docker-ce docker-ce-cli containerd.io

echo "*** Adding vagrant user to the docker group, to be able to run docker command without the need to use sudo ..."
sudo usermod -aG docker vagrant

echo "*** Enabling docker daemon to start on boot ..."
sudo systemctl enable docker

echo "*** Starting the docker service ..."
sudo systemctl start docker
