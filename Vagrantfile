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
  ## Ansible Controller
  ##
  # The "controller" string is the name of the box. hence you can do "vagrant up controller"
  config.vm.define "controller" do |controller_config|
    controller_config.vm.box = "controller.box"
    
	# this set's the machine's hostname. 
	controller_config.vm.hostname = "controller.local"  

	
	# This will appear when you do "ip addr show". You can then access your guest machine's website using "http://192.168.50.4" 
	controller_config.vm.network "private_network", ip: "192.168.50.100"  
	# note: this approach assigns a reserved internal ip addresses, which virtualbox's builtin router then reroutes the traffic to,
	#see: https://en.wikipedia.org/wiki/Private_network 
	
    controller_config.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = true
      
      # For common vm settings, e.g. setting ram and cpu we use:
      vb.memory = "1024"
	  vb.cpus = 2
	  
	  # adding a second hdd to my vm. 
	  # https://gist.github.com/leifg/4713995
	  
	  #   docker_storage = './tmp/docker.vdi'
	  #   unless File.exist?(docker_storage)
      #     vb.customize ['createhd', '--filename', docker_storage, '--size', 50 * 1024]     # This is 50GB, 
      #   end
      #   vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', docker_storage]
	  
	  
	  # However for more obscure virtualbox specific settings we fall back to virtualbox's "modifyvm" command:
	  vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
 
      # name of machine that appears on the vb console and vb consoles title. 	  
	  vb.name = "ansible-controller"    
    end

	# Copy git server related .pem files from the host machine to the guest machine. this is to allow git clone commands to run using https links rather than http. 
#	controller_config.vm.provision :host_shell do |host_shell|
#      host_shell.inline = "[ -d /c/vagrant-personal-files/GitServerCertificates ] && cp -rf /c/vagrant-personal-files/GitServerCertificates ./personal-data/GitServerCertificates"
#    end
#	controller_config.vm.provision "shell", path: "scripts/copy-GitServerCertificates-into-vm.sh"		
#	controller_config.vm.provision "shell", path: "docker/install-docker.sh"
    controller_config.vm.provision "shell", path: "scripts/install-ansible.sh"
	
	# Copy the .gitconfig file from the host machine to the guest machine
 	controller_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = "cp -f ${HOME}/.gitconfig ./personal-data/.gitconfig"
    end
    controller_config.vm.provision "shell" do |s| 
 	  s.inline = '[ -f /vagrant/personal-data/.gitconfig ] && runuser -l vagrant -c "cp -f /vagrant/personal-data/.gitconfig ~"'
    end
 
    ## Copy the public+private keys from the host machine to the guest machine
 	controller_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = "[ -f ${HOME}/.ssh/id_rsa ] && cp -f ${HOME}/.ssh/id_rsa* ./personal-data/"
    end
 	controller_config.vm.provision "shell", path: "scripts/import-ssh-keys.sh"

	# Here we are setting up ssh passwordless communication with clients. 
    controller_config.vm.provision "shell", path: "scripts/setup-ansible-controller-ssh-keys.sh"		


	# Here we are telling the controller what clients it is allowed to control. 
    controller_config.vm.provision "shell", path: "scripts/populate-ansible-inventory.sh"		


 	
    # for some reason I have to restart network, but this needs more investigation 
    controller_config.vm.provision "shell" do |remote_shell|
      remote_shell.inline = "systemctl restart network"
    end
	
 	# this takes a vm snapshot (which we have called "basline") as the last step of "vagrant up". 
 	controller_config.vm.provision :host_shell do |host_shell|
      host_shell.inline = 'vagrant snapshot take controller baseline'
    end
	
  end

  
  
  
  
  
  ##
  ## Ansible Clients - linux 7 boxes
  ##  
  (1..2).each do |i|  
    config.vm.define "ansibleclient0#{i}" do |ansibleclient_config|
      ansibleclient_config.vm.box = "client.box"
      ansibleclient_config.vm.hostname = "ansibleclient0#{i}.local"  
      ansibleclient_config.vm.network "private_network", ip: "192.168.50.10#{i}"  
      ansibleclient_config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "1024"
        vb.cpus = 1
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        vb.name = "ansibleclient0#{i}"    
      end

      # for some reason I have to restart network, but this needs more investigation 
      ansibleclient_config.vm.provision "shell" do |remote_shell|
        remote_shell.inline = "systemctl restart network"
      end
      
	  # Here we are setting up ssh passwordless communication when connection request recieved by the controller. 	  
	  ansibleclient_config.vm.provision "shell", path: "scripts/setup-ansible-client-ssh-keys.sh"
	  
      # this takes a vm snapshot (which we have called "basline") as the last step of "vagrant up". 
      ansibleclient_config.vm.provision :host_shell do |host_shell|
        host_shell.inline = "vagrant snapshot take ansibleclient0#{i} baseline"
      end
      
    end
  end
    
  # this line relates to the vagrant-hosts plugin, https://github.com/oscar-stack/vagrant-hosts
  # it adds entry to the /etc/hosts file. 
  # this block is placed outside the define blocks so that it gts applied to all VMs that are defined in this vagrantfile. 
  config.vm.provision :hosts do |provisioner|
    provisioner.add_host '192.168.50.100', ['controller', 'controller.local']  
    provisioner.add_host '192.168.50.101', ['ansibleclient01', 'ansibleclient01.local']
    provisioner.add_host '192.168.50.102', ['ansibleclient02', 'ansibleclient02.local']
  end
  
  config.vm.provision :host_shell do |host_shell|
    host_shell.inline = 'hostfile=/c/Windows/System32/drivers/etc/hosts && grep -q 192.168.50.100 $hostfile || echo "192.168.50.100   controller controller.local" >> $hostfile'
  end
  
  config.vm.provision :host_shell do |host_shell|
    host_shell.inline = 'hostfile=/c/Windows/System32/drivers/etc/hosts && grep -q 192.168.50.101 $hostfile || echo "192.168.50.101   ansibleclient01 ansibleclient01.local" >> $hostfile'
  end  

  config.vm.provision :host_shell do |host_shell|
    host_shell.inline = 'hostfile=/c/Windows/System32/drivers/etc/hosts && grep -q 192.168.50.102 $hostfile || echo "192.168.50.102   ansibleclient02 ansibleclient02.local" >> $hostfile'
  end 
end
