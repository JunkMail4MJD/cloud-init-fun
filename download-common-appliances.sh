#!/bin/bash
printf "\nDownloading Ubuntu 16.04 LTS and 18.04 LTS cloud-init appliances\n\n"
curl -Lo appliances/ubuntu-16.04-server-cloudimg-amd64.ova http://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64.ova
curl -Lo appliances/ubuntu-18.04-server-cloudimg-amd64.ova http://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.ova
