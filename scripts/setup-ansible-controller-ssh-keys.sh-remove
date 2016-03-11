#!/bin/bash
echo "INFO: About to run setup-ansible-puppetmaster-ssh-keys.sh"

cp /vagrant/files/ssh-keys/puppetmaster/.ssh /root/ -rf

chown --recursive root:root /root/.ssh

chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub
# chmod 644 /root/.ssh/known_hosts

# this disables RSA fingerprint checking when connecting to a new host. 
echo "
Host *
    StrictHostKeyChecking no
" > /root/.ssh/config