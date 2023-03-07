#!/bin/bash

echo "*** Downloading the repository information..."
sudo wget https://pkg.jenkins.io/redhat/jenkins.repo -O /etc/yum.repos.d/jenkins.repo

echo "*** Importing the repository key..."
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key

echo "*** Install jenkins ..."
sudo dnf install -y jenkins

echo "*** Change jenkins user password ..."
sudo chpasswd <<<"jenkins:Password1"

echo "*** Set shell to /bin/bash ..."
sudo usermod -s /bin/bash jenkins

echo "*** Adding jenkins user to the sudoers list ..."
sudo echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

echo "*** Enabling jenkins service to start on boot ..."
sudo systemctl enable jenkins

echo "*** Starting the jenkins service ..."
sudo systemctl start jenkins

echo "*** Download jenkins-cli.jar ..."
sudo rm jenkins-cli.jar
wget http://192.168.34.201:8080/jnlpJars/jenkins-cli.jar || true

echo "*** Copy script file for creating and build pipeline with jenkins-cli.jar ..."
sudo rm create-jenkins-job.sh
sudo cp /vagrant/create-jenkins-job.sh .
