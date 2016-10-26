#!/bin/bash

echo '##########################################################################'
echo '################ About to run update-git.sh script #######################'
echo '##########################################################################'

# http://tecadmin.net/install-git-2-x-on-centos-rhel-and-fedora/#


yum -y install wget || exit 1
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker

cd /usr/src
wget https://www.kernel.org/pub/software/scm/git/git-2.8.1.tar.gz 
tar xzf git-2.8.1.tar.gz

cd git-2.8.1
make prefix=/usr/local/git all
make prefix=/usr/local/git install
echo "export PATH=/usr/local/git/bin:$PATH" >> /etc/bashrc
source /etc/bashrc

# git config --global push.default simple
