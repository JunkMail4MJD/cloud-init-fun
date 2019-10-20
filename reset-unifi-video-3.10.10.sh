#!/usr/bin/env bash
VBoxManage controlvm video poweroff
VBoxManage snapshot  video restore freshInstall
VBoxManage startvm   video --type headless

