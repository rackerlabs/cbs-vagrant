# Install Vagrant

# Install Vagrant plugins

$ vagrant plugin install vagrant-vbguest
$ vagrant plugin install vagrant-cachier

NOTE: if you get the following error after ``vagrant up`` -  ``Unknown
configuration section 'vbguest'`` You must install the vagrant-vbguest plugin

# Checkout Havana Cinder

$ git clone https://github.com/openstack/cinder.git
$ git checkout -b havana 3d967e05ea082cbb755586e07e21f2b070d0bdb3

# Checkout Lunr and lunrdriver

$ git clone https://github.rackspace.com/BigData/lunr.git
$ git clone https://github.rackspace.com/BigData/lunrdriver.git

# Checkout python-cinderclient and python-lunrclient (Optional)

$ git clone https://github.rackspace.com/BigData/python-cinderclient.git
$ git clone https://github.rackspace.com/BigData/python-lunrclient.git
