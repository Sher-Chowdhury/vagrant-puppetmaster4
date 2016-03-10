#!/bin/bash

# http://docs.ansible.com/ansible/intro_inventory.html
echo "INFO: About to run scripts/populate-ansible-inventory.sh"

mv /etc/ansible/hosts /etc/ansible/hosts-orig   || exit 1

cp /vagrant/files/hosts /etc/ansible/  || exit 1

exit 0