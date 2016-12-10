#!/bin/bash
echo '##########################################################################'
echo '########About to run agent-network-connectivity-test.sh script ###########'
echo '##########################################################################'

sudo yum install -y telnet || exit 1

#Puppet master should be set as 192.168.51.100
sudo telnet puppetmaster 22 #Need to add some way to exit gracefully with the telnet command

echo "Network SSH Connection Achieved!"
