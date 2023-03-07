#!/bin/bash

echo "*** Firewall - disable ..."
sudo systemctl stop firewalld
sudo systemctl disable --now firewalld
# OR
# echo "*** Firewall - open needed ports - port 80/tcp, 8080/tcp ..."
# sudo firewall-cmd --permanent --add-port=80/tcp
# sudo firewall-cmd --permanent --add-port=8080/tcp
# sudo firewall-cmd --reload
