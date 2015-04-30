# What is this?

cbs-vagrant is a salt/vagrant project that magicly creates a new lunr/cinder
development environment from scratch using virtualbox and saltstack

# Installation
Before vagrant can do it's magic, you must install lunr and cinder packages
into an accesable directory on the host machine. (Your laptop/desktop)

## Install Vagrant
See https://www.vagrantup.com

Vagrant uses virtualbox by default, and I've only tested this project with virtualbox.

## Install Vagrant plugins
These are needed by the ``Vagrantfile`` config

```
$ vagrant plugin install vagrant-vbguest
$ vagrant plugin install vagrant-cachier
```

# Setup your development environment
Create a directory to checkout all the required git repos
```
$ mkdir ~/cbs-dev
$ cd ~/cbs-dev
```

## Checkout Havana Cinder
```
$ git clone https://github.com/openstack/cinder.git
$ git checkout -b havana 3d967e05ea082cbb755586e07e21f2b070d0bdb3
```

## Checkout Lunr and lunrdriver
```
$ git clone https://github.rackspace.com/BigData/lunr.git
$ git clone https://github.rackspace.com/BigData/lunrdriver.git
```

## Checkout python-cinderclient and python-lunrclient (Optional)
```
$ git clone https://github.rackspace.com/BigData/python-cinderclient.git
$ git clone https://github.rackspace.com/BigData/python-lunrclient.git
```

## Checkout the cbs-vagrant project
```
$ git clone git@github.rackspace.com:derr0215/cbs-vagrant.git
```

## Run vagrant
Vagrant will create a new virtualbox instance and mount the ``~/dev`` directory
inside the new virtual box instance as ``/vagrant``. It will then provision the
instance using saltstack by downloading pip and package dependencies.

```
$ cd ~/cbs-dev/cbs-vagrant
$ vagrant up
```

## Log into the new instance
Either ssh into the instance
```
$ ssh 192.168.14.4
```
Or ask vagrant to ssh in
```
$ vagrant ssh api
```
