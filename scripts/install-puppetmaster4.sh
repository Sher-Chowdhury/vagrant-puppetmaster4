#!/bin/bash

echo '##########################################################################'
echo '##### About to run install-puppetmaster4.sh script #######################'
echo '##########################################################################'


# this is really important:
# http://docs.puppetlabs.com/puppet/4.3/reference/whered_it_go.html#new-codedir-holds-all-modulesmanifestsdata


# This shows the location of all the various puppet config files. 
# https://github.com/puppetlabs/puppet-specifications/blob/master/file_paths.md#puppetserver

# puppet.conf is now stored in /etc/puppetlabs/puppet/puppet.conf   
# This is specified here:
# http://docs.puppetlabs.com/puppet/4.3/reference/whered_it_go.html#nix-confdir-is-now-etcpuppetlabspuppet

# The environments folder (/etc/puppet/environment) is now located at: 
# http://docs.puppetlabs.com/puppet/4.3/reference/whered_it_go.html#new-codedir-holds-all-modulesmanifestsdata


rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm  || exit 1

yum install -y puppetserver || exit 1


# https://docs.puppetlabs.com/puppetserver/latest/install_from_packages.html#memory-allocation
sed -i s/^JAVA_ARGS/#JAVA_ARGS/g /etc/sysconfig/puppetserver || exit 1
#echo 'JAVA_ARGS="-Xms512m -Xmx512m -XX:MaxPermSize=256m"' >> /etc/sysconfig/puppetserver
echo 'JAVA_ARGS="-Xms512m -Xmx512m"' >> /etc/sysconfig/puppetserver


# http://docs.puppetlabs.com/puppet/4.3/reference/whered_it_go.html
echo "PATH=$PATH:/opt/puppetlabs/bin" >> /root/.bashrc

# this is so to get the puppetmaster to autosign puppet agent certificicates. 
# This means that you no longer need to do "puppet cert sign...etc"
# https://docs.puppetlabs.com/puppet/latest/reference/ssl_autosign.html#basic-autosigning-autosignconf
# https://docs.puppetlabs.com/puppet/latest/reference/config_file_autosign.html

puppet config set autosign true
# echo '*' >> /etc/puppet/autosign.conf   # this line doesn't work in puppet4, may need to change this to something a bit different, or just use the above command if you 
                                          # want global allow permissions. 

systemctl enable puppetserver
systemctl start puppetserver
systemctl status puppetserver
