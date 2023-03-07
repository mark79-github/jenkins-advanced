#!/bin/bash

java -jar jenkins-cli.jar -s http://localhost:8080/ -ssh -user admin create-job bgapp < /vagrant/Jenkinsfile.xml
java -jar jenkins-cli.jar -s http://localhost:8080/ -ssh -user admin build bgapp -f -v
