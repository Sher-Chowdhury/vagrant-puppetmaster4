# -*- mode: ruby -*-
# vi: set ft=ruby :


# http://stackoverflow.com/questions/19492738/demand-a-vagrant-plugin-within-the-vagrantfile
# not using 'vagrant-vbguest' vagrant plugin because now using bento images which has vbguestadditions preinstalled.
required_plugins = %w( vagrant-hosts vagrant-host-shell vagrant-triggers )
plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end



Vagrant.configure(2) do |config|
  ##
  ##  puppet5master
  ##
  # The "puppet5master" string is the name of the box. hence you can do "vagrant up puppet5555master"
  config.vm.define "puppet5master" do |puppet5master_config|
    # puppet5master_config.vm.box = "centos/7" # not using this anymore because vbguest nees to be preinstalled, otherwise the vagrant folder
    # only syncs on the initial vagrant up, but not anymore after that....for more info see: https://github.com/mitchellh/vagrant/issues/7811
    # I'm using bento boxes because they have vbguestadditions preinstalled, so that sync folders works straight away.
    puppet5master_config.vm.box = "bento/centos-7.3"

    # this set's the machine's hostname.
    puppet5master_config.vm.hostname = "puppetmaster.local"


    # This will appear when you do "ip addr show". You can then access your guest machine's website using "http://192.168.50.5"
    puppet5master_config.vm.network "private_network", ip: "192.168.51.100"
    # note: this approach assigns a reserved internal ip addresses, which virtualbox's builtin router then reroutes the traffic to,
    #see: https://en.wikipedia.org/wiki/Private_network

    puppet5master_config.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      # For common vm settings, e.g. setting ram and cpu we use:
      vb.memory = "2048"
      vb.cpus = 2
      # However for more obscure virtualbox specific settings we fall back to virtualbox's "modifyvm" command:
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      # name of machine that appears on the vb console and vb consoles title.
      vb.name = "puppet5master"
    end

    puppet5master_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = "cp -f ${HOME}/.gitconfig ./personal-data/.gitconfig"
    end

    puppet5master_config.vm.provision "shell" do |s|
      s.inline = '[ -f /vagrant/personal-data/.gitconfig ] && runuser -l vagrant -c "cp -f /vagrant/personal-data/.gitconfig ~"'
    end

    ## Copy the public+private keys from the host machine to the guest machine
    puppet5master_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = "[ -f ${HOME}/.ssh/id_rsa ] && cp -f ${HOME}/.ssh/id_rsa* ./personal-data/"
    end
    puppet5master_config.vm.provision "shell", path: "scripts/import-ssh-keys.sh"

    puppet5master_config.vm.provision "shell", path: "scripts/install-puppet5master.sh"
    puppet5master_config.vm.provision "shell", path: "scripts/update-git.sh"
    puppet5master_config.vm.provision "shell", path: "scripts/install-vim-puppet-plugins.sh", privileged: false
    # for some reason I have to restart network if host machine is a windows machine, but this needs more investigation
    puppet5master_config.vm.provision "shell" do |remote_shell|
      remote_shell.inline = "systemctl stop firewalld"
      remote_shell.inline = "systemctl disable firewalld"
      remote_shell.inline = "systemctl stop NetworkManager"
      remote_shell.inline = "systemctl disable NetworkManager"
      remote_shell.inline = "systemctl restart network"
    end

    # this takes a vm snapshot (which we have called "basline") as the last step of "vagrant up".
#    puppet5master_config.vm.provision :host_shell do |host_shell|
#      host_shell.inline = 'vagrant snapshot save puppet5master baseline'
#    end

  end

  ##
  ## Puppet agents - linux 7 boxes
  ##
  (1..2).each do |i|
    config.vm.define "puppet5agent0#{i}" do |puppet5agent_config|
      puppet5agent_config.vm.box = "bento/centos-7.3"
      puppet5agent_config.vm.hostname = "puppetagent0#{i}.local"
      puppet5agent_config.vm.network "private_network", ip: "192.168.51.10#{i}"
      puppet5agent_config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "1024"
        vb.cpus = 1
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        vb.name = "puppet5agent0#{i}"
      end

      puppet5agent_config.vm.provision "shell", path: "scripts/install-puppet5-agent.sh"

      # this takes a vm snapshot (which we have called "basline") as the last step of "vagrant up".
 #     puppet5agent_config.vm.provision :host_shell do |host_shell|
 #       host_shell.inline = "vagrant snapshot save puppet5agent0#{i} baseline"
 #     end

      # for some reason I have to restart network if host machine is a windows machine, but this needs more investigation
      puppet5agent_config.vm.provision "shell" do |remote_shell|
        remote_shell.inline = "systemctl stop firewalld"
        remote_shell.inline = "systemctl disable firewalld"
        remote_shell.inline = "systemctl stop NetworkManager"
        remote_shell.inline = "systemctl disable NetworkManager"
        remote_shell.inline = "systemctl restart network"
      end

    end
  end

  # this line relates to the vagrant-hosts plugin, https://github.com/oscar-stack/vagrant-hosts
  # it adds entry to the /etc/hosts file.
  # this block is placed outside the define blocks so that it gets applied to all VMs that are defined in this vagrantfile.
  config.vm.provision :hosts do |provisioner|
    provisioner.add_host '192.168.51.100', ['puppetmaster', 'puppetmaster.local']
    provisioner.add_host '192.168.51.101', ['puppetagent01', 'puppetagent01.local']
    provisioner.add_host '192.168.51.102', ['puppetagent02', 'puppetagent02.local']
  end

end
