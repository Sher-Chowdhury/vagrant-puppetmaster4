#!/bin/bash

echo '##########################################################################'
echo '########About to run agent-network-connectivity-test.sh script ###########'
echo '##########################################################################'

sudo yum install -y telnet || exit 1

#Puppet master should be set as 192.168.51.100
sudo telnet 192.168.51.100 || echo "Network Connection to Puppet master failed" && exit 1 

echo "Network Connection Achieved!"
