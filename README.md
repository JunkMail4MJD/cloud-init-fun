# cloud-init-fun
playing around with cloud-init images


## Pre-Requisites

* Docker Installed
* Virtual Box Installed

## Download ubuntu cloud images

Run this script to download the most recent Ubuntu LTS versions

      ./download-common-images.sh

You can download these manually in a web browser
* [http://cloud-images.ubuntu.com/releases/16.04/release/](http://cloud-images.ubuntu.com/releases/16.04/release/)
* [http://cloud-images.ubuntu.com/releases/18.04/release/](http://cloud-images.ubuntu.com/releases/18.04/release/)

## Example scripts

Here are some example scripts to get you started exploring what is possible with Ubuntu cloud images.



**Create a generic Ubuntu 16.04 LTS VM running NGINX**

      ./create-generic-vm.sh generic-16-04-LTS images/ubuntu-16.04-server-cloudimg-amd64.vmdk

* The generic VM example script creates a new virtual machine with 1 CPU 2 GB of RAM and a 100GB virtual drive.
* It shows you how to setup users, set a password, give SUDO privileges and run a one time startup script to install software.
* This script updates APT, installs docker and runs a NGINX web server
* If your DHCP server supports dynamic registration of DNS names on your network based on the computer names that it issues IP addresses to then your can pull up NGINX at the following address HTTP://generic-16-04-LTS
* The script generates a new unique SSH Key Pair for every virtual machine
* The command to ssh into your new VM is printed as the final output of the script
* For a more secure server, delete the configuration lines that set root user password
* With no root user password set it will be impossible to log into the box with anything other than the SSH Key that was created and stored on you machine



**Create a generic Ubuntu 18.04 LTS VM running NGINX**

      ./create-generic-vm.sh generic-18-04-LTS images/ubuntu-18.04-server-cloudimg-amd64.vmdk

* This example script is the same as the previous example with the only change being that it uses a different version of the operating system
* This shows how you can upgrade the operating system underneath your application without any fuss
* If your DHCP server supports dynamic registration of DNS names on your network based on the computer names that it issues IP addresses to then your can pull up NGINX at the following address HTTP://generic-18-04-LTS
* The script generates a new unique SSH Key Pair for every virtual machine
* The command to ssh into your new VM is printed as the final output of the script
* For a more secure server, delete the configuration lines that set root user password
* With no root user password set it will be impossible to log into the box with anything other than the SSH Key that was created and stored on you machine



**Minimal Kubernetes Playground**

      ./create-vm-minikube-installed.sh mini-installed images/ubuntu-18.04-server-cloudimg-amd64.vmdk

* This example script builds on the previous example with a slightly more complex startup script
* It creates a VM with docker, kubectl and minikube installed but no cluster setup
* This script only installs the software, it intentionally does not create a kubernetes cluster for you
* The intention is that you will ssh into the virtual machine and get experience and practice setting up your own minikube based kubernetes cluster
* The script generates a new unique SSH Key Pair for every virtual machine
* The command to ssh into your new VM is printed as the final output of the script
* For a more secure server, delete the configuration lines that set root user password
* With no root user password set it will be impossible to log into the box with anything other than the SSH Key that was created and stored on you machine


**Kubernetes Playground with a minimal cluster setup**

      ./create-basic-minikube-vm.sh mini-basic-cluster images/ubuntu-18.04-server-cloudimg-amd64.vmdk


* This example script builds on the previous example with a slightly more complex startup script
* It creates a VM with docker, kubectl and minikube installed AND sets up a kubernetes cluster
* The intention is that you will ssh into the virtual machine and get experience and practice deploying applications into a running kubernetes cluster
* The cluster has the kubernetes dashboard installed and running
* if your DHCP / DNS servers support it then the dashboard should be accessible at http://mini-basic-cluster:31080
* Additionally the EFK monitoring and logging stack is installed and ready to go it should be available at http://mini-basic-cluster:30003
* It may take a few minutes for it to startup and render a screen properly
* When it comes up there will be a screen asking you to create an index
* It pre-populates the logstash* index in the field to create an index
* Just go ahead and submit the page to create the index
* Then go to the discover page and wait a bit to start seeing the cluster logs populate the screen
* Lastly the NGINX ingress is installed and enabled
* No routing rules are mapped on the the ingress
* It is ready for you to start populating rules yourself
* If you like you can edit the script and replace it with Istio
* The script generates a new unique SSH Key Pair for every virtual machine
* The command to ssh into your new VM is printed as the final output of the script
* For a more secure server, delete the configuration lines that set root user password
* With no root user password set it will be impossible to log into the box with anything other than the SSH Key that was created and stored on you machine


## Cleanup when you are done

    ./cleanup-vm.sh generic-16-04-LTS
    ./cleanup-vm.sh generic-18-04-LTS
    ./cleanup-vm.sh mini-installed
    ./cleanup-vm.sh mini-basic-cluster


* These commands will stop and delete all of the virtual machines that just created
* It will also delete all of the files related to those virtual machines
* That includes the SSH Key pairs we created, user-data and meta-data configuration files and final ISO file that was used to load into the virtual machine at a startup
* Don't worry you can easily recreate an identical virtual machine by just running the script again with the same inputs...
* However, when you try to SSH into the machine it will fail because there is a new server key
* See below for how to fix that

## Cleanup when Reusing server names

* If you destroy and recreate a machine with the same name as it's predecessor and you've been ssh-ing into the box then its fingerprint will have changed in the process of recreating the box. The SSH client will assume that there is a man in the middle attack underway and won't let you ssh into the box. This is easily fixed by just deleting your ssh known hosts file.

      rm ~/.ssh/known_hosts

* if you can't remember the command above there is a script to remind you called flush-known-hosts.sh. You can run it by sourcing it.

      source ./flush-known-hosts.sh

