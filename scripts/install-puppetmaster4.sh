#!/bin/bash

# this is really important:
# http://docs.puppetlabs.com/puppet/4.3/reference/whered_it_go.html#new-codedir-holds-all-modulesmanifestsdata


# This shows the location of all the various puppet config files. 
# https://github.com/puppetlabs/puppet-specifications/blob/master/file_paths.md#puppetserver

# puppet.conf is now stored in /etc/puppetlabs/puppet/puppet.conf   
# This is specified here:
# http://docs.puppetlabs.com/puppet/4.3/reference/whered_it_go.html#nix-confdir-is-now-etcpuppetlabspuppet

# The environments folder (/etc/puppet/environment) is now located at: 
# http://docs.puppetlabs.com/puppet/4.3/reference/whered_it_go.html#new-codedir-holds-all-modulesmanifestsdata


rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

yum install puppetserver

systemctl enable puppetserver
systemctl start puppetserver




