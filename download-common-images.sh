#!/bin/bash
mkdir images
printf "\nDownloading Ubuntu 16.04 LTS and 18.04 LTS cloud-init disk images\n\n"

curl -Lo            raw-images/ubuntu-16.04-server-cloudimg-amd64.vmdk http://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64-disk1.vmdk
VBoxManage clonehd  raw-images/ubuntu-16.04-server-cloudimg-amd64.vmdk images/ubuntu-16.04-server-cloudimg-amd64.vdi --format vdi

curl -Lo            raw-images/ubuntu-18.04-server-cloudimg-amd64.vmdk http://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.vmdk
VBoxManage clonehd  raw-images/ubuntu-18.04-server-cloudimg-amd64.vmdk images/ubuntu-18.04-server-cloudimg-amd64.vdi --format vdi
