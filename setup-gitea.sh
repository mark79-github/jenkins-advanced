#!/bin/bash

echo "*** Deploying Gitea..."
docker compose -f /vagrant/docker-compose-gitea.yaml down  || true
docker compose -f /vagrant/docker-compose-gitea.yaml up -d
