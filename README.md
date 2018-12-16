# cloud-init-fun
playing around with cloud-init images


## Pre-Requisites

* have a machine running ubuntu
* install Virtual Box
* install cloud-init tools

      sudo apt-get install qemu-utils genisoimage cloud-utils


## Download ubuntu cloud images from here
* [http://cloud-images.ubuntu.com/releases/16.04/release/](http://cloud-images.ubuntu.com/releases/16.04/release/)
* [http://cloud-images.ubuntu.com/releases/18.04/release/](http://cloud-images.ubuntu.com/releases/18.04/release/)


## Create a generic VM running NGINX

    ./create-generic-vm.sh generic-01 ubuntu-18.04-server-cloudimg-amd64.ova


## Create a minikube VM to play with kubernetes

    ./create-minikube-vm.sh mini-01 ubuntu-18.04-server-cloudimg-amd64.ova

## Cleanup when you are done

    ./cleanup-vm.sh generic-01
    ./cleanup-vm.sh mini-01


