
##################
# Pip Packages
################

lunr-pip-packages:
  pip.installed:
    - requirements: /vagrant/lunr/requirements.txt
    - bin_env:  /opt/lunr-virtualenv
    - user: vagrant
    - require:
      - virtualenv: /opt/lunr-virtualenv
      - pkg: python-pip
      - pkg: python-virtualenv
      - pkg: python-dev
      - pkg: libffi-dev

lunr-pip-mysql-packages:
  pip.installed:
    - name: mysql
    - bin_env:  /opt/lunr-virtualenv
    - user: vagrant
    - require:
      - virtualenv: /opt/lunr-virtualenv
      - pkg: python-pip
      - pkg: python-virtualenv
      - pkg: python-dev
      - pkg: libmysqlclient-dev


##################
# Directories
################

/opt/lunr-virtualenv:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - recurse:
      - user
      - group
  virtualenv.managed:
    - system_site_packages: False
    - user: vagrant
    - reload_modules: true
    - require:
      - file: /opt/lunr-virtualenv

/etc/lunr:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - recurse:
      - user
      - group

/etc/lunr/run:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - recurse:
      - user
      - group

/var/run/lunr:
  file.directory:
    - makedirs: True
    - user: vagrant
    - group: vagrant

/etc/lunr/backups:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - recurse:
      - user
      - group

/var/log/lunr:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - mode: 755

/var/log/orbit:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - mode: 755

/var/log/storage:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - mode: 755


##################
# Files
################

/etc/iet/ietd.conf:
  file.managed:
    - create: False
    - user: vagrant
    - group: vagrant
    - require:
      - pkg: iscsitarget

/etc/default/iscsitarget:
  file.managed:
    - source: salt://files/etc/default/iscsitarget

/etc/cgconfig.conf:
  file.managed:
    - source: salt://files/etc/cgconfig.conf

/etc/lunr/storage-server.conf:
  file.managed:
    - source: salt://files/etc/lunr/storage-server.conf
    - template: jinja

/etc/lunr/api-server.conf:
  file.managed:
    - source: salt://files/etc/lunr/api-server.conf
    - template: jinja

/etc/lunr/orbit.conf:
  file.managed:
    - source: salt://files/etc/lunr/orbit.conf
    - template: jinja

/etc/init.d/lunr-screen:
  file.managed:
    - source: salt://files/etc/init.d/lunr-screen
    - mode: 755

/etc/lunr/lunr.screenrc:
  file.managed:
    - source: salt://files/etc/lunr/lunr.screenrc

/usr/bin/install-lunr.py:
  file.managed:
    - source: salt://files/usr/bin/install-lunr.py
    - mode: 755

/usr/bin/setup-lunr.py:
  file.managed:
    - source: salt://files/usr/bin/setup-lunr.py
    - mode: 755

/usr/bin/setup-storage.py:
  file.managed:
    - source: salt://files/usr/bin/setup-storage.py
    - mode: 755

/usr/bin/lunr-screen:
  file.symlink:
    - target: /vagrant/lunr/bin/lunr-screen

/usr/bin/lunr-reset:
  file.symlink:
    - target: /vagrant/lunr/bin/lunr-reset

/home/vagrant/lunr-virtualenv:
  file.symlink:
    - target: /opt/lunr-virtualenv/bin/activate

/etc/sudoers.d/lunr:
  file.managed:
    - source: salt://files/etc/sudoers.d/lunr
    - mode: 440

/etc/sudoers.d/lunr-test:
  file.managed:
    - source: salt://files/etc/sudoers.d/lunr-tests
    - mode: 440

/etc/motd.tail:
  file.managed:
    - source: salt://files/etc/motd.tail
    - mode: 644

/home/vagrant/.bashrc:
  file.managed:
    - source: salt://files/home/vagrant/bashrc
    - user: vagrant
    - group: vagrant
    - mode: 644

/root/.bashrc:
  file.managed:
    - source: salt://files/home/vagrant/bashrc
    - mode: 644

/etc/iscsi/initiatorname.iscsi:
  file.managed:
    - mode: 600
    - user: vagrant
    - group: vagrant


##################
# Services
################

service-lunr-screen:
  service:
    - name: lunr-screen
    - running
    - sig: /usr/bin/SCREEN -dm -c /etc/lunr/lunr.screenrc
    - require:
      - file: /etc/init.d/lunr-screen
      - mysql_database: lunr-database

service-cgconfig:
  service.running:
    - name: cgconfig
    - watch:
      - file: /etc/cgconfig.conf
    - require:
      - pkg: cgroup-bin


##################
# Setup Lunr
################

install-lunr:
  cmd.run:
    - name: /usr/bin/install-lunr.py
    - creates: /opt/lunr-virtualenv/lib/python2.7/site-packages/lunr.egg-link
    - user: vagrant
    - cwd: /
    - require:
      - file: /usr/bin/install-lunr.py
      - virtualenv: /opt/lunr-virtualenv
    - require_in:
      - service: service-lunr-screen

setup-lunr:
  cmd.run:
    - name: /usr/bin/setup-lunr.py
    - user: vagrant
    - cwd: /
    - unless: /opt/lunr-virtualenv/bin/lunr-admin type get vtype
    - require:
      - file: /usr/bin/setup-lunr.py
      - mysql_database: lunr-database
      - virtualenv: /opt/lunr-virtualenv

setup-storage:
  cmd.run:
    - name: /usr/bin/setup-storage.py
    - unless: pvs | grep lunr-volume
    - cwd: /
    - require:
      - file: /usr/bin/setup-storage.py
      - virtualenv: /opt/lunr-virtualenv
      - mysql_database: lunr-database
    - require_in:
      - service: service-lunr-screen


##################
# Misc
################

lunr-database:
  mysql_database.present:
    - name: lunr
    - require:
      - service: service-mysql

