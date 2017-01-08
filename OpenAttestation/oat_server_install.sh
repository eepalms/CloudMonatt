#!/bin/bash

# Install the OpenAttestation Server

OAT_PATH=/root/OpenAttestation

apt-get install -y openjdk-6-jdk libtspi-dev zip ant g++ make git apache2 mysql-client mysql-server mysql-common php5 php5-mysql openssl libmysql-java

echo "ServerName localhost" >> /etc/apache2/httpd.conf

/etc/init.d/apache2 restart

cd $OAT_PATH/Source
./distribute_jar_packages.sh

cd $OAT_PATH/Installer
./deb.sh -s $OAT_PATH/Source

dpkg -i /tmp/debbuild/DEBS/x86_64/OAT-*.deb
