#!/bin/bash
# step 1: 安装repo
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# step 2: 安装依赖的软件
yum install -y yum-utils device-mapper-persistent-data lvm2
# step 3: 设置yum源
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# Step 4: 更新并安装Docker-CE
yum install docker-ce
# Step 5: 启动docker
systemctl enable docker
systemctl start docker