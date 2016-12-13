#!/bin/bash
echo '##########################################################################'
echo '########About to run agent-network-connectivity-test.sh script ###########'
echo '##########################################################################'

sudo yum install -y nmap-ncat.x86_64 2:6.40-7.el7 || exit 1

#Puppet master should be set as 192.168.51.100
nc -w 2 -v puppetmaster 8140 </dev/null || exit 1

echo "Network Puppet Master Server Connection Achieved!"
