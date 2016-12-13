# -*- mode: ruby -*-
# vi: set ft=ruby :


# http://stackoverflow.com/questions/19492738/demand-a-vagrant-plugin-within-the-vagrantfile
required_plugins = %w( vagrant-hosts vagrant-share vagrant-vbguest vagrant-vbox-snapshot vagrant-host-shell vagrant-triggers vagrant-reload )
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
  ##  puppet4master
  ##
  # The "puppet4master" string is the name of the box hence you can do "vagrant up puppet4master"
  config.vm.define "puppet4master" do |puppet4master_config|

    # Box used is https://github.com/holms/vagrant-centos7-box/releases/download/7.1.1503.001/CentOS-7.1.1503-x86_64-netboot.box
    puppet4master_config.vm.box = "CentOS7.0"

    # this set's the machine's hostname.
    puppet4master_config.vm.hostname = "puppetmaster.local"

    # This will appear when you do "ip addr show". You can then access your guest machine's website using "http://192.168.50.4"
    puppet4master_config.vm.network "private_network", ip: "192.168.51.100"
    # note: this approach assigns a reserved internal ip addresses, which virtualbox's builtin router then reroutes the traffic to,
    #see: https://en.wikipedia.org/wiki/Private_network

    puppet4master_config.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      # For common vm settings, e.g. setting ram and cpu we use:
      vb.memory = "2048"
      vb.cpus = 1
      # However for more obscure virtualbox specific settings we fall back to virtualbox's "modifyvm" command:
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      # name of machine that appears on the vb console and vb consoles title.
      vb.name = "puppet4master"
    end

    puppet4master_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = "cp -f ${HOME}/.gitconfig ./personal-data/.gitconfig"
    end

    puppet4master_config.vm.provision "shell" do |s|
      s.inline = '[ -f /vagrant/personal-data/.gitconfig ] && runuser -l vagrant -c "cp -f /vagrant/personal-data/.gitconfig ~"'
    end

    ## Copy the public+private keys from the host machine to the guest machine
    puppet4master_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = "[ -f ${HOME}/.ssh/id_rsa ] && cp -f ${HOME}/.ssh/id_rsa* ./personal-data/"
    end

    puppet4master_config.vm.provision "shell", path: "scripts/import-ssh-keys.sh"
    puppet4master_config.vm.provision "shell", path: "scripts/install-puppet4master.sh"
    puppet4master_config.vm.provision "shell", path: "scripts/update-git.sh"
    puppet4master_config.vm.provision "shell", path: "scripts/install-vim-puppet-plugins.sh", privileged: false

    #Stop the default centos7 firewall service
    puppet4master_config.vm.provision "shell" do |remote_shell|
      remote_shell.inline = "sudo systemctl stop firewalld"
      remote_shell.inline = "sudo systemctl disable firewalld"
      remote_shell.inline = "sudo systemctl stop firewalld"
    end

    # this takes a vm snapshot (which we have called "baseline") as the last step of "vagrant up".
    puppet4master_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = 'vagrant snapshot take puppet4master baseline'
    end
  end

  ##
  ## Puppet agents - Centos 7 boxes
  ##

  #Loop increments number of puppet agents
  (1..2).each do |i|
    config.vm.define "puppet4agent0#{i}" do |puppet4agent_config|
      # Box used is https://github.com/holms/vagrant-centos7-box/releases/download/7.1.1503.001/CentOS-7.1.1503-x86_64-netboot.box
      puppet4agent_config.vm.box = "CentOS7.0"
      puppet4agent_config.vm.hostname = "puppetagent0#{i}.local"
      puppet4agent_config.vm.network "private_network", ip: "192.168.51.10#{i}" #So puppet4agent01 would have a last octect of 101, 02 is 102 etc.
      puppet4agent_config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "1024"
        vb.cpus = 1
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        vb.name = "puppet4agent0#{i}"
      end

      #Stop the default centos7 firewall service
      puppet4agent_config.vm.provision "shell" do |remote_shell|
        remote_shell.inline = "sudo systemctl stop firewalld"
	remote_shell.inline = "sudo systemctl disable firewalld"
	remote_shell.inline = "sudo systemctl stop firewalld"
      end	

      puppet4agent_config.vm.provision "shell", path: "scripts/install-puppet4-agent.sh"

      #Network Connectivity Test to Puppet master - agent must be run after puppet master has been set up and is running
      config.vm.provision "shell", path: "scripts/agent-network-connectivity-test.sh"

      # this takes a vm snapshot (which we have called "basline") as the last step of "vagrant up".
      puppet4agent_config.vm.provision :host_shell do |host_shell|
        host_shell.inline = "vagrant snapshot take puppet4agent0#{i} baseline"
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
