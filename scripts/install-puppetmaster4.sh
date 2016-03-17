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
echo 'JAVA_ARGS="-Xms512m -Xmx512m"' >> /etc/sysconfig/puppetserver || exit 1


# http://docs.puppetlabs.com/puppet/4.3/reference/whered_it_go.html
echo "PATH=$PATH:/opt/puppetlabs/bin" >> /root/.bashrc || exit 1
PATH=$PATH:/opt/puppetlabs/bin || exit 1
puppet --version || exit 1

# this is so to get the puppetmaster to autosign puppet agent certificicates. 
# This means that you no longer need to do "puppet cert sign...etc"
# https://docs.puppetlabs.com/puppet/latest/reference/ssl_autosign.html#basic-autosigning-autosignconf
# https://docs.puppetlabs.com/puppet/latest/reference/config_file_autosign.html

puppet config set autosign true
# echo '*' >> /etc/puppet/autosign.conf   # this line needs fixing, see:
					  # https://docs.puppetlabs.com/puppet/latest/reference/config_file_autosign.html 


##
## The following is a direct copy taken from puppet 3.8 config file. So need to investigate which parts I need. 
##
## https://docs.puppetlabs.com/puppet/latest/reference/config_about_settings.html
## https://docs.puppetlabs.com/puppet/latest/reference/configuration.html
echo '[agent]' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    # The file in which puppetd stores a list of the classes'  >> /etc/puppetlabs/puppet/puppet.conf
#echo '    # associated with the retrieved configuration.  Can be loaded in'  >> /etc/puppetlabs/puppet/puppet.conf
#echo '    # the separate ``puppet`` executable using the ``--loadclasses``' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    # option.' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    # The default value is '$statedir/classes.txt'.' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    classfile = $statedir/classes.txt' >> /etc/puppetlabs/puppet/puppet.conf

#echo '    # Where puppetd caches the local configuration.  An' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    # extension indicating the cache format is added automatically.' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    # The default value is '$confdir/localconfig'.' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    localconfig = $vardir/localconfig' >> /etc/puppetlabs/puppet/puppet.conf

#echo '    # Disable the default schedules as they cause continual skipped'  >> /etc/puppetlabs/puppet/puppet.conf
#echo '    # resources to be displayed in Foreman - only for Puppet >= 3.4' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    default_schedules = false' >> /etc/puppetlabs/puppet/puppet.conf

#echo '    report            = true' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    pluginsync        = true' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    masterport        = 8140' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    environment       = production' >> /etc/puppetlabs/puppet/puppet.conf
echo '    certname          = puppet4master.local' >> /etc/puppetlabs/puppet/puppet.conf
echo '    server            = puppet4master.local' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    listen            = false' >> /etc/puppetlabs/puppet/puppet.conf     # this no longer exists. 
#echo '    splay             = false' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    splaylimit        = 1800' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    runinterval       = 1800' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    noop              = false' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    configtimeout     = 120' >> /etc/puppetlabs/puppet/puppet.conf
#echo '    usecacheonfailure = true' >> /etc/puppetlabs/puppet/puppet.conf












systemctl enable puppetserver || exit 1
systemctl start puppetserver  || exit 1
systemctl status puppetserver || exit 1
