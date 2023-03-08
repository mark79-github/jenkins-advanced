# DevOps - Containerization, CI/CD &amp; Monitoring - January 2023 - SoftUni

## Advanced CI/CD with Jenkins

1. **Creating Vagrantfile which creates two virtual machine with the following configuration:**
    - Jenkins
      - Box: **`shekeriev/centos-stream-9`**
      - Host names: **`jenkins.martin.bg`**
      - Private network with dedicated IPs: **`192.168.34.201`**
      - Forwarded port - "guest:host": **`8080:8080`**
      - Provisioning via provided bash scripts: [**`setup-update.sh`**](setup-update.sh), [**`setup-hosts.sh`**](setup-hosts.sh), [**`setup-firewall.sh`**](setup-firewall.sh), [**`setup-packages.sh`**](setup-packages.sh) and [**`setup-jenkins.sh`**](setup-jenkins.sh)
      - Shared folder configuration: **`jenkins/`** -> **`/vagrant`**
      - Set virtual machine memory size: **`3072`**
    - Docker
      - Box: **`shekeriev/centos-stream-9`**
      - Host names: **`docker.martin.bg`**
      - Private network with dedicated IPs: **`192.168.34.202`**
      - Provisioning via provided bash scripts: [**`setup-update.sh`**](setup-update.sh), [**`setup-hosts.sh`**](setup-hosts.sh), [**`setup-firewall.sh`**](setup-firewall.sh), [**`setup-packages.sh`**](setup-packages.sh), [**`setup-docker.sh`**](setup-docker.sh), [**`setup-add-user.sh`**](setup-add-user.sh) and [**`setup-gitea.sh`**](setup-gitea.sh)
      - Shared folder configuration: **`"docker/"`** -> **`"/vagrant"`**
      - Set virtual machine memory size: **`3072`**
    - Create after trigger event to get initial jenkins administrator password
    - Create another after trigger event to open default browser to configure Jenkins at [**`http://localhost:8080`**](http://localhost:8080) or [**`http://192.168.34.201:8080`**](http://192.168.34.201:8080)
2. **Additional Jenkins VM setup:**
    - Log into jenkins machine: **`vagrant ssh jenkins`**
    - Change user to jenkins: **`su - jenkins`**
    - Create ssh keys: **`ssh-keygen -t rsa -m PEM`**
    - Copy ssh key to the jenkins host: **`ssh-copy-id jenkins@jenkins.martin.bg`**
    - Copy ssh key to the docker host:  **`ssh-copy-id jenkins@docker.martin.bg`**
3. **Additional Jenkins setup at [**`http://localhost:8080`**](http://localhost:8080) or [**`http://192.168.34.201:8080`**](http://192.168.34.201:8080)**
    - Enter initial administration password: **`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`**
    - Install suggested plugins
    - Add administrator account
    - Manage Jenkins -> Manage Credentials -> Global Credentials -> Add Credentials
      - SSH username with private key:
        - ID: **`SSH`**
        - Description: **`Username with private key`**
        - Username: **`jenkins`**
        - Private key -> Enter directly: **`sudo cat /var/lib/jenkins/.ssh/id_rsa`**
        - Username with password:
          - Username: username from [**`https://hub.docker.com`**](https://hub.docker.com)
          - Password: access token from [**`https://hub.docker.com`**](https://hub.docker.com)
          - ID: **`docker-hub`**
          - Description: **`docker-hub`**
    - Manage Jenkins -> Manage Plugins -> Available Plugins
      - **`SSH plugin`** version 2.6.1
      - **`Gitea plugin`** version 1.4.5
    - Manage Jenkins -> Configure System -> SSH remote hosts -> Add
      - Hostname: **`jenkins.martin.bg`**
      - Port: **`22`**
      - Credentials: **`jenkins (Username with private key)`**
      - SSH remote hosts: **`curl -Lv http://192.168.34.201:8080/login 2>&1 | grep -i 'x-ssh-endpoint'`**
    - Manage Jenkins -> Manage Nodes and Clouds -> New Node
      - Node name: **`docker-node`**
      - Type: Permanent Agent
        - Number of executors: **`4`**
        - Remote root directory: **`/home/jenkins`**
        - Labels: **`docker-node`**
        - Usage: **`Only build jobs with label expressions matching this node`**
        - Launch method: **`Launch agents via SSH`**
          - Host: **`docker.martin.bg`**
          - Credentials: **`jenkins (Username with private key)`**
    - Manage Jenkins -> Configure Global Security -> SSH Server
      - Fixed: **`2222`**
      - Test SSH Server
        - exit jenkins session on jenkins VM
        - **`ssh -l admin -p 2222 localhost who-am-i`**
    - Manage Jenkins -> Manage Users -> Edit User (cogwheel)
      - Create SSH keys for vagrant user on jenkins machine: **`ssh-keygen`**
      - Configure user SSH Public Keys with created public SSH key: **`cat ~/.ssh/id_rsa.pub`**
4. **Additional Gitea setup at [**`http://192.168.34.202:3000`**](http://192.168.34.202:3000)**
    - Administrator Account Settings
      - Administrator Username: **`douser`**
      - Password: **`Password1`**
    - Install Gitea
    - New migration -> Git
      - Migrate / Clone from URL: [**`https://github.com/mark79-github/bgapp.git`**](https://github.com/mark79-github/bgapp.git)
      - Owner: **`douser`**
      - Repository Name: **`bgapp`**
    - Repository setup at [**`http://192.168.34.202:3000/douser/bgapp`**](http://192.168.34.202:3000/douser/bgapp)
        - Target URL: **`http://192.168.34.201:8080/gitea-webhook/post`**
5. **Create & build Jenkins pipeline with jenkins-cli.jar using import configuration file [**`Jenkinsfile.xml`**](jenkins/Jenkinsfile.xml) from shared folder:**
    - Execute bash script: [**`sh create-jenkins-job.sh`**](jenkins/create-jenkins-job.sh)
6. **Pipeline job has following configuration:**
    - Environment variables used in pipeline code
    - Agent: **`docker-node`**
    - Several stages for process automation:
      - Downloading the project from your Gitea repository
        - [**`http://192.168.34.202:3000/douser/bgapp.git`**](http://192.168.34.202:3000/douser/bgapp.git)
      - Prepare volumes
        - create folder "web" to host needed files for web server volume
      - Deploy on development
        - using **`docker-compose.yaml`** from development folder to build images from **`Dockerfile.web`** & **`Dockerfile.db`**
      - Testing the application for reachability on development
        - test if containers are up & running and curl command returns status code 200
        - sleep for 30 seconds - needed for db server to be up & running successfully
        - test if db show data for some city
      - Publishing the images to Docker Hub
        - try to login to [**`https://hub.docker.com`**](https://hub.docker.com) with environment credentials
        - tag & push to repository the created images
      - Stopping the application and removing the containers
        - docker compose down using **`docker-compose.yaml`** from development folder
      - Deploy on production
        - docker compose up using **`docker-compose.yaml`** from production folder
    - Post stage to clear workspace
7. **The result can be seen at [**`http://192.168.34.202`**](http://192.168.34.202)**
