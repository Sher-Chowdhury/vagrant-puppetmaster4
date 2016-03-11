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
  ##  puppetmaster
  ##
  # The "puppetmaster" string is the name of the box. hence you can do "vagrant up puppetmaster"
  config.vm.define "puppetmaster" do |puppetmaster_config|
    puppetmaster_config.vm.box = "master4.box"

    # this set's the machine's hostname.
    puppetmaster_config.vm.hostname = "puppetmaster.local"


    # This will appear when you do "ip addr show". You can then access your guest machine's website using "http://192.168.50.4"
    puppetmaster_config.vm.network "private_network", ip: "192.168.50.100"
    # note: this approach assigns a reserved internal ip addresses, which virtualbox's builtin router then reroutes the traffic to,
    #see: https://en.wikipedia.org/wiki/Private_network

    puppetmaster_config.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = true
      # For common vm settings, e.g. setting ram and cpu we use:
      vb.memory = "1024"
      vb.cpus = 2
      # However for more obscure virtualbox specific settings we fall back to virtualbox's "modifyvm" command:
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      # name of machine that appears on the vb console and vb consoles title.
      vb.name = "puppetmaster"
    end

    puppetmaster_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = "cp -f ${HOME}/.gitconfig ./personal-data/.gitconfig"
    end

    puppetmaster_config.vm.provision "shell" do |s|
      s.inline = '[ -f /vagrant/personal-data/.gitconfig ] && runuser -l vagrant -c "cp -f /vagrant/personal-data/.gitconfig ~"'
    end

    ## Copy the public+private keys from the host machine to the guest machine
    puppetmaster_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = "[ -f ${HOME}/.ssh/id_rsa ] && cp -f ${HOME}/.ssh/id_rsa* ./personal-data/"
    end
    puppetmaster_config.vm.provision "shell", path: "scripts/import-ssh-keys.sh"

    puppetmaster_config.vm.provision "shell", path: "scripts/install-puppetmaster4.sh"

    # for some reason I have to restart network, but this needs more investigation
    puppetmaster_config.vm.provision "shell" do |remote_shell|
      remote_shell.inline = "systemctl restart network"
    end

   # this takes a vm snapshot (which we have called "basline") as the last step of "vagrant up".
   puppetmaster_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = 'vagrant snapshot take puppetmaster baseline'
    end

  end

  ##
  ## Puppet agents - linux 7 boxes
  ##
  (1..2).each do |i|
    config.vm.define "puppetagent0#{i}" do |puppetagent_config|
      puppetagent_config.vm.box = "client.box"
      puppetagent_config.vm.hostname = "puppetagent0#{i}.local"
      puppetagent_config.vm.network "private_network", ip: "192.168.50.10#{i}"
      puppetagent_config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "1024"
        vb.cpus = 1
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        vb.name = "puppetagent0#{i}"
      end

      # for some reason I have to restart network, but this needs more investigation
      puppetagent_config.vm.provision "shell" do |remote_shell|
        remote_shell.inline = "systemctl restart network"
      end

    # Here we are setting up ssh passwordless communication when connection request recieved by the puppetmaster.
    puppetagent_config.vm.provision "shell", path: "scripts/setup-ansible-client-ssh-keys.sh"

      # this takes a vm snapshot (which we have called "basline") as the last step of "vagrant up".
      puppetagent_config.vm.provision :host_shell do |host_shell|
        host_shell.inline = "vagrant snapshot take puppetagent0#{i} baseline"
      end

    end
  end

  # this line relates to the vagrant-hosts plugin, https://github.com/oscar-stack/vagrant-hosts
  # it adds entry to the /etc/hosts file.
  # this block is placed outside the define blocks so that it gts applied to all VMs that are defined in this vagrantfile.
  config.vm.provision :hosts do |provisioner|
    provisioner.add_host '192.168.50.100', ['puppetmaster', 'puppetmaster.local']
    provisioner.add_host '192.168.50.101', ['puppetagent01', 'puppetagent01.local']
    provisioner.add_host '192.168.50.102', ['puppetagent02', 'puppetagent02.local']
  end

  config.vm.provision :host_shell do |host_shell|
    host_shell.inline = 'hostfile=/c/Windows/System32/drivers/etc/hosts && grep -q 192.168.50.100 $hostfile || echo "192.168.50.100   puppetmaster puppetmaster.local" >> $hostfile'
  end

  config.vm.provision :host_shell do |host_shell|
    host_shell.inline = 'hostfile=/c/Windows/System32/drivers/etc/hosts && grep -q 192.168.50.101 $hostfile || echo "192.168.50.101   puppetagent01 puppetagent01.local" >> $hostfile'
  end

  config.vm.provision :host_shell do |host_shell|
    host_shell.inline = 'hostfile=/c/Windows/System32/drivers/etc/hosts && grep -q 192.168.50.102 $hostfile || echo "192.168.50.102   puppetagent02 puppetagent02.local" >> $hostfile'
  end
end
