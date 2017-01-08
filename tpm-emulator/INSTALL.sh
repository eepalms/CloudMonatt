#!/bin/bash

TPM_PATH=/root/tpm-emulator

# Download dependencies
apt-get update
apt-get install -y libgmp3c2 libgmp3-dev g++ make cmake subversion trousers tpm-tools

# Install the tpm-emulator
cd $TPM_PATH
mkdir build
cd build
cmake ../
make
make install

# Start the tpm-emulator service
depmod
modprobe tpmd_dev
modprobe tpm
tpmd
tcsd
