#!/bin/bash

echo "*** Create user - jenkins ..."
sudo useradd jenkins
sudo chpasswd <<<"jenkins:Password1"

echo "*** Adding jenkins user to the sudoers list ..."
sudo echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

echo "*** Adding the jenkins user to the docker group ..."
sudo usermod -aG docker jenkins

echo "*** Restarting docker service ..."
sudo systemctl restart docker
