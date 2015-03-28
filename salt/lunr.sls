
##################
# Packages
################

lvm2:
  pkg.installed: []

iscsitarget:
  pkg.installed: []

open-iscsi:
  pkg.installed: []

cgroup-bin:
  pkg.installed: []

screen:
  pkg.installed: []

curl:
  pkg.installed: []

qemu-utils:
  pkg.installed: []

blktap-utils:
  pkg.installed: []

libffi-dev:
  pkg.installed: []

python-dev:
  pkg.installed: []

python-pip:
  pkg.installed:
    - reload_modules: true

python-virtualenv:
  pkg.installed: []

syslog-ng:
  pkg.installed: []

mysql-server:
  pkg.installed: []

mysql-client:
  pkg.installed: []

libmysqlclient-dev:
  pkg.installed: []

python-mysqldb:
  pkg.installed: []

python-requests:
  pkg.installed: []

# Required by 'pip freeze'
git:
  pkg.installed: []

# For Precise
iscsitarget-dkms:
  pkg.installed:
    - skip_verify: True
    - force_yes: True


##################
# Pip Packages
################

pip-packages:
  pip.installed:
    - requirements: /vagrant/lunr/requirements.txt
    - bin_env:  /var/vagrant/lunr-virtualenv
    - user: vagrant
    - require:
      - virtualenv: /var/vagrant/lunr-virtualenv
      - pkg: python-pip
      - pkg: python-virtualenv
      - pkg: python-dev
      - pkg: libffi-dev

pip-mysql-packages:
  pip.installed:
    - name: mysql
    - bin_env:  /var/vagrant/lunr-virtualenv
    - user: vagrant
    - require:
      - virtualenv: /var/vagrant/lunr-virtualenv
      - pkg: python-pip
      - pkg: python-virtualenv
      - pkg: python-dev
      - pkg: libmysqlclient-dev


##################
# Directories
################

/var/vagrant/lunr-virtualenv:
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
      - file: /var/vagrant/lunr-virtualenv

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

/var/log/cinder:
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

/etc/syslog-ng/conf.d/cbs.conf:
  file.managed:
    - source: salt://files/etc/syslog-ng/conf.d/cbs.conf
    - template: jinja
    - require:
      - pkg: syslog-ng
    - watch_in:
      - service: service-syslog-ng

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
    - target: /var/vagrant/lunr-virtualenv/bin/activate

/home/vagrant/cinder-virtualenv:
  file.symlink:
    - target: /var/vagrant/cinder-virtualenv/bin/activate

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

/home/vagrant/.bashrc
  file.managed:
    - source: salt://files/home/vagrant/bashrc
    - user: vagrant
    - group: vagrant
    - mode: 644

/root/.bashrc
  file.managed:
    - source: salt://files/home/vagrant/bashrc
    - mode: 644

/etc/iscsi/initiatorname.iscsi:
  file.managed:
    - mode: 600
    -user: vagrant
    -group: vagrant


##################
# Services
################

service-syslog-ng:
  service:
    - name: syslog-ng
    - running

service-ssh:
  service:
    - name: ssh
    - running

service-lunr-screen:
  service:
    - name: lunr-screen
    - running
    - sig: /usr/bin/SCREEN -dm -c /etc/lunr/lunr.screenrc
    - require:
      - file: /etc/init.d/lunr-screen
      - mysql_database: lunr-database

service-mysql:
  service.running:
    - name: mysql
    - require:
      - pkg: mysql-server

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
    - creates: /var/vagrant/lunr-virtualenv/lib/python2.7/site-packages/lunr.egg-link
    - user: vagrant
    - cwd: /
    - require:
      - file: /usr/bin/install-lunr.py
      - virtualenv: /var/vagrant/lunr-virtualenv
    - require_in:
      - service: service-lunr-screen

setup-lunr:
  cmd.run:
    - name: /usr/bin/setup-lunr.py
    - user: vagrant
    - cwd: /
    - unless: /var/vagrant/lunr-virtualenv/bin/lunr-admin type get vtype
    - require:
      - file: /usr/bin/setup-lunr.py
      - mysql_database: lunr-database
      - mysql_database: cinder-database
      - virtualenv: /var/vagrant/lunr-virtualenv

setup-storage:
  cmd.run:
    - name: /usr/bin/setup-storage.py
    - unless: pvs | grep lunr-volume
    - cwd: /
    - require:
      - file: /usr/bin/setup-storage.py
      - virtualenv: /var/vagrant/lunr-virtualenv
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

cinder-database:
  mysql_database.present:
    - name: cinder
    - require:
      - service: service-mysql


