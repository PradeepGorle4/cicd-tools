#!/bin/bash

#resize disk from 20GB to 50GB

growpart /dev/nvme0n1 4  # Resizing the Partition

# Resizing the Logical Volume
lvextend -L +10G /dev/RootVG/rootVol 
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -L +5G /dev/mapper/RootVG-homeVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

# Resizing File System
xfs_growfs /
xfs_growfs /var/tmp
xfs_growfs /var
xfs_growfs /home


curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install fontconfig java-17-openjdk jenkins -y
yum install jenkins -y
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

