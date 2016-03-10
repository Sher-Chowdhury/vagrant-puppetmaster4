#!/bin/bash
echo "INFO: About to run setup-ansible-client-ssh-keys.sh"
cp /vagrant/files/ssh-keys/client/.ssh /root/ -rf

chown --recursive root:root /root/.ssh

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

exit 0
# this disables RSA fingerprint checking when connecting to a new host. 
echo "
Host *
    StrictHostKeyChecking no
" > /root/.ssh/config