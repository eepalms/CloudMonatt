#!/bin/bash

# default
dist="fedora"

#ec storage type, file or NVARM
ecStorage=-ecs
sed -i  "s/^ecStorage.*$/ecStorage = NVRAM/g" OATprovisioner.properties
if [ $# -ge 2 ];then
  if [ $1 = $ecStorage ];then
    sed -i  "s/^ecStorage.*$/ecStorage = $2/g" OATprovisioner.properties
  fi
fi

# check distrition
if [ -f /etc/issue ]; then
if [ -n "`grep -i 'ubuntu' /etc/issue`" ]; then
    echo "Linux distribution is Ubuntu"
    dist="ubuntu"
fi

if [ -n "`grep -i 'suse' /etc/issue`" ]; then
    echo "Linux distribution is SUSE"
    dist="suse"
fi

if [ -n "`grep -i 'fedora' /etc/issue`" ]; then
    echo "Linux distribution is Fedora"
    dist="fedora"
fi
fi


# unpack OAT client files
if [ -d /OAT/ ]; then 
rm -rf /OAT/*
else
mkdir /OAT/
fi
chmod -R a+w /OAT/

cp shells/$dist.sh /OAT/OAT.sh
chmod +x /OAT/OAT.sh
cp -f OAT_Standalone.jar /OAT
touch /OAT/log4j.properties
cp -rf lib/ /OAT 
cp -f /OAT/OAT.sh /etc/init.d/OATClient
cp -f OAT.properties /OAT
cp -f TrustStore.jks /OAT
cp -f NIARL_TPM_Module /OAT
cp -f attestation_kernel /OAT
cp -f formats /OAT

rm -f /OAT/uninstallOAT.sh
echo "/etc/init.d/OATClient stop" >> /OAT/uninstallOAT.sh
echo "rm -rf /OAT" >> /OAT/uninstallOAT.sh
echo "rm -f /etc/init.d/OATClient" >> /OAT/uninstallOAT.sh

# let it run at startup
if [ "$dist" = "fedora" ]; then
    ln -fs /etc/init.d/OATClient /etc/rc5.d/S99OATClient
    ln -fs /etc/init.d/OATClient /etc/rc3.d/S99OATClient
    chkconfig OATClient on
    echo "rm -f /etc/rc5.d/S99OATClient" >> /OAT/uninstallOAT.sh
    echo "rm -f /etc/rc3.d/S99OATClient" >> /OAT/uninstallOAT.sh
fi

if [ "$dist" = "suse" ]; then
    ln -fs /etc/init.d/OATClient /etc/init.d/rc5.d/S99OATClient
    ln -fs /etc/init.d/OATClient /etc/init.d/rc3.d/S99OATClient
    chkconfig OATClient on
    echo "rm -f /etc/init.d/rc5.d/S99OATClient" >> /OAT/uninstallOAT.sh
    echo "rm -f /etc/init.d/rc3.d/S99OATClient" >> /OAT/uninstallOAT.sh
fi

if [ "$dist" = "ubuntu" ]; then
    update-rc.d OATClient defaults 99
    update-rc.d OATClient enable
    echo "update-rc.d OATClient disable" >> /OAT/uninstallOAT.sh
    echo "update-rc.d -f OATClient remove" >> /OAT/uninstallOAT.sh
fi

# OAT provisioning
bash provisioner.sh
