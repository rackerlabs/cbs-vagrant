# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :machine
  end

  # Ensure ubuntu vm has the latest version of VirtualBox Guest Additions
  # (Requires vagrant-vbguest plugin)
  config.vbguest.auto_update = true

  # The IP Address ends in 12.4 to indicate 12.04, Update it when we change versions
  config.vm.network "private_network", ip: "192.168.12.4"

  config.vm.box = "ubuntu-14.04-amd64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  # Disable the default shared directory
  #config.vm.synced_folder ".", "/vagrant", disabled: true
  # Instead share our parent directory to /vagrant
  config.vm.synced_folder "..", "/vagrant", create: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    # Needs atleast 1 Gig of memory
    vb.memory = "1024"

    # Stackoverflow says this is required to give the virtualbox internet access
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # Create a 10 GIG disk for lunr to provision from
    disk = 'lunr-volume.vdi'
    size = 10

    # If the disk doesn't already exist create it
    unless File.exist?(disk)
      vb.customize ['createhd', '--filename', disk, '--size', size * 1024, '--format', 'VDI']
    end

    # Note: my version of vagrant created a storage controller with the name
    # 'SATA Controller'. This might not be the same for others but
    vb.customize ['storageattach', :id, '--storagectl', 'SATAController',
                  '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]

  end

  config.vm.define "api" do |api|
    # Mount the salt directory, for masterless
    api.vm.synced_folder "salt/", "/srv/salt/"
    # Run the salt minion
    api.vm.provision :salt do |salt|
      salt.minion_config = 'salt.minion'
      salt.bootstrap_options = '-P'
      salt.colorize = true
      salt.run_highstate = true
      salt.verbose = true
    end
  end

end
