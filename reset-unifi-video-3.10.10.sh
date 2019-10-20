#!/usr/bin/env bash
VBoxManage controlvm video31010 poweroff
VBoxManage snapshot  video31010 restore freshInstall
VBoxManage startvm   video31010 --type headless

