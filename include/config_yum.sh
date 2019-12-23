#!/bin/bash

# configure yum repolist
if [ "`yum repolist | sed -n '/repolist/p' |awk '{print $2}'`" = "0" ]; then
    if [ ${CentOS_ver} = "6" ]; then
       cat > /etc/yum.repos.d/CentOS-zju.repo <<EOF
[base]
name=CentOS-$releasever - Base
baseurl=http://mirrors.zju.edu.cn/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

[updates]
name=CentOS-$releasever - Updates
baseurl=http://mirrors.zju.edu.cn/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

[extras]
name=CentOS-$releasever - Extras
baseurl=http://mirrors.zju.edu.cn/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
EOF
    elif [ ${CentOS_ver} = "7" ]; then
    cat > /etc/yum.repos.d/CentOS-zju.repo <<EOF
[base]
name=CentOS-$releasever - Base
baseurl=http://mirrors.zju.edu.cn/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates
baseurl=http://mirrors.zju.edu.cn/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras
baseurl=http://mirrors.zju.edu.cn/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
fi