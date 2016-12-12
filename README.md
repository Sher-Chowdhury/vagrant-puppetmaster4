vagrant-puppetmaster4

### Overview

The vagrant project is a 3 Centos7 vm development environment, i.e.:  

```
$ vagrant status
Current machine states:

puppetmaster            not created (virtualbox)
puppetagent01           not created (virtualbox)
puppetagent02           not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Here we have the puppetmaster vm, this has the free version of puppetmaster installed on it. puppetagent01 and puppetagent02 only have the puppet agent installed on them.


### Pre-reqs

#### Install necessary software
you need to have the following installed on your host machine:

* [virtualbox](https://www.virtualbox.org/)  
* [vagrant](https://www.vagrantup.com/)
* gitbash or cygwin - (if you are using running vagrant on a windows laptop/workstation)

Once they are all installed, do the following (not required for macs):

1. right click on the virtualbox icon,
2. go to properties,
3. select the shortcut tab
4. click on the "advanced" button
5. enable the "Run as Administrator" checkbox
6. Then apply and save changes
7. Repeat the above steps, but this time for Git bash, You can find this icon under, start -> All programs -> git -> Git Bash


#### Setup git on your host machine.
Open up a bash/cygyin/gitbash terminal and ensure the following files exist in the following folder:

```
ls -l ~/.ssh
-rw-------  1 schowdhury  staff  1679  6 Sep 15:52 id_rsa
-rw-r--r--  1 schowdhury  staff   406  7 Sep 11:10 id_rsa.pub
```


If you don't, then run the ssh-keygen command to get it generated. These files will get copied to your vagrant boxes so that you can passwordlessly using git repos from inside your git boxes.

Now ensure you can ~/.gitconfig exists, with at least the user.name and user.email entries, if not then you can generate it by running the following commands:

```
$ git config --global user.name "FirstName LastName"
$ git config --global user.email "MyEmailAddress@example.com"
$ git config --global core.autocrlf false
$ git config --global push.default simple
```
This file will then get copied to the

### Pre-reqs (optional, but recommended)


On your (linux, e.g. Apple MacBook) host machine, create the following folder and add the following files:

```
$ ls -l /c/vagrant-personal-files/
total 1
-rw-r--r--    1 SChowdhu Administ      210 Apr 20  2015 hiera.yaml
-rw-r--r--    1 SChowdhu Administ      291 Sep 30 08:52 r10k.yaml
```

However if your host machine is a windows machine, then create folder "C:\vagrant-personal-files" and place the above files in there instead.




### Set up

Start a bash/cygwin terminal

cd into the project folder and run the following:


```sh
$ vagrant up puppet4master
```

This will take about 20 minutes to complete, but depends on your machine specs and internet connections.



There are also 2 CentOS 7 clients that you can start up:


```sh
$ vagrant up puppet4agent01
$ vagrant up puppet4agent02
```
Note, you can increase/decrease the number of agents by tweaking the for loop in the Vagrantfile.


### Update your host machine's host file

You should append the following lines to your host file:

```
192.168.50.100   puppet4master puppet4master.local
192.168.50.101   puppet4agent01 puppet4agent01.local
192.168.50.102   puppet4agent02 puppet4agent02.local
```

If your host machine, then update then your host file is located at:

```sh
$ sudo vim /etc/hosts
```

And for Window's users the host file is likely to be here:

```
c:\Windows\System32\drivers\etc\hosts
```

Having thes in place will allow you to things via your laptops/workstations web browser, e.g. if you installed apache web server on puppet4agent01, then you can view it in firefox/chrome by navigating to http://puppet4agent01.local


### Login credentials
you can ssh into all your machines using the following credential:

```
username: vagrant
password: vagrant
```

Therefore you can do (using puppetmaster.local as an example):

```sh
$ ssh vagrant@puppetmaster.local
```

You can also log in using the following credentials:

```
username: root
password: vagrant
```

Note, it is common practice to login as the vagrant user, then do 'sudo -i' to become root.


If you want to login as the vagrant user, then you can do it with the following shorthand technique, e.g.:

```sh
$ vagrant ssh puppet4master
```

This approach is handy in case you didn't know what the vagrant user's password is.



### Auto snapshots

On accasions you'll want to reset your vagrant boxes. This is usually done by doing "vagrant destroy" followed by "vagrant up". This can be time consuming. A much faster approach is to use virtualbox snapshots instead.


For each vm, a virtualbox is taken towards the end of your "vagrant up". This snapshot is called "baseline". If you want to roll back to this snapshot, then you do:

```sh
$ vagrant snapshot go puppet4master baseline
```

...or for an puppet agent, e.g. puppetagent01, you do:

```sh
$ vagrant snapshot go puppet4agent01 baseline
```

### Start all over again
If you want to start from the beginning again, then do:

```sh
$ vagrant destroy --force
$ vagrant box list
$ vagrant box remove {box name}
```
