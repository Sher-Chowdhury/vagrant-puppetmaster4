#!/bin/bash

# http://docs.ansible.com/ansible/intro_installation.html#latest-release-via-yum
echo "INFO: About to run scripts/install-ansible.sh"
yum install python-devel -y  || exit 1     # this package is in the "base" yum repo
yum install python2-crypto -y  || exit 1
yum install asciidoc -y  || exit 1
yum install rpm-build -y  || exit 1

cd /tmp ||  exit 1
git clone git://github.com/ansible/ansible.git --recursive  || exit 1
cd ansible  || exit 1
make rpm  || exit 1
git checkout tags/v2.0.0.1-1  || exit 1
cd rpm-build/  || exit 1
yum localinstall ansible-*.noarch.rpm -y  || exit 1

echo "line 14"
echo "INFO: Ansible has been successfully installed"
yum info ansible  || exit 1
exit 0


# Ignore the rest, it's no longer required.

useradd ansible
echo "vagrant" | passwd --stdin ansible

runuser -l ansible -c 'git clone git://github.com/ansible/ansible.git --recursive'  

runuser -l ansible -c 'cd ansible'

runuser -l ansible -c 'git checkout tags/v2.0.0.1-1'

runuser -l ansible -c 'source ./hacking/env-setup '

runuser -l ansible -c 'echo "source /home/ansible/ansible/hacking/env-setup 1>/dev/null 2>&1" >> /home/ansible/.bashrc'


easy_install pip

yum install python-devel -y     # this package is in the "base" yum repo

pip install paramiko PyYAML Jinja2 httplib2 six

runuser -l ansible -c 'ansible --version'
