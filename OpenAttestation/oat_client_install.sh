#!/bin/bash

# Install the OpenAttestation Client

SERVER_IP=172.16.0.1

apt-get install -y trousers libtspi1 openjdk-6-jre zip

wget http://$SERVER_IP/ClientInstallForLinux.zip

unzip ClientInstallForLinux.zip

cd ClientInstallForLinux
sh general-install.sh

/etc/init.d/OATClient start
