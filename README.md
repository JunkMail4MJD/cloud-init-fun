# cloud-init-fun
playing around with cloud-init images


## Pre-Requisites

* Docker Installed
* Virtual Box Installed

## Download ubuntu cloud images from here or use the script below
* [http://cloud-images.ubuntu.com/releases/16.04/release/](http://cloud-images.ubuntu.com/releases/16.04/release/)
* [http://cloud-images.ubuntu.com/releases/18.04/release/](http://cloud-images.ubuntu.com/releases/18.04/release/)

      ./download-common-appliances.sh

## Create a generic Ubuntu 16.04 LTS VM running NGINX


      ./create-generic-vm.sh generic-16 appliances/ubuntu-16.04-server-cloudimg-amd64.ova

## Create a generic Ubuntu 18.04 LTS VM running NGINX

      ./create-generic-vm.sh generic-18 appliances/ubuntu-18.04-server-cloudimg-amd64.ova

## Create a VM with kubectl and minikube installed but no cluster setup to play with kubernetes

      ./create-vm-minikube-installed.sh mini-installed appliances/ubuntu-18.04-server-cloudimg-amd64.ova

## Create a VM with kubectl and minikube installed and a basic cluster setup

      ./create-basic-minikube-vm.sh mini-basic-18 appliances/ubuntu-18.04-server-cloudimg-amd64.ova

## Cleanup when Reusing server names

If you destroy and recreate a machine with the same name as it's predecessor and you've been ssh-ing into the box then its fingerprint will have changed in the process of recreating the box. The SSH client will assume that there is a man in the middle attack underway and won't let you ssh into the box. This is easily fixed by just deleting your ssh known hosts file. 

      rm ~/.ssh/known_hosts

## Cleanup when you are done

    ./cleanup-vm.sh generic-18
    ./cleanup-vm.sh mini-installed
    ./cleanup-vm.sh mini-basic-18
