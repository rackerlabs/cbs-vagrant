# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # The IP Address ends in 14.4 to indicate 14.04, Update it when we change versions
  config.vm.box = "ubuntu-14.04-amd64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.network "private_network", ip: "192.168.14.4"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    # Needs atleast 1 Gig of memory
    vb.memory = "1024"

    # Stackoverflow says this is required to give the virtualbox internet access
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # Create a 10 GIG disk for lunr to provision from
    disk = './lunr-volume.vdi'
    size = 10

    # If the disk doesn't already exist create it
    unless File.exist?(disk)
      vb.customize ['createhd', '--filename', disk, '--size', size * 1024, '--format', 'VDI']
    end

    # Attach the disk
    vb.customize ['storageattach', :id, '--storagectl', 'SATAController',
                  '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]

    # Note: my version of vagrant created a storage controller with the name 'SATA Controller'. This might not be the same for others but
  end

  config.vm.define "api" do |api|
    # Mount the salt directory, for masterless
    api.vm.synced_folder "salt/", "/srv/salt/"
    # Run the salt minion
    api.vm.provision :salt do |salt|
      salt.minion_config = 'salt.minion'
      salt.colorize = true
      salt.run_highstate = true
      salt.verbose = true
    end
  end

end
