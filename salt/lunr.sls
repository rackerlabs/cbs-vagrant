
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
  pkg.installed: []

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
      - file: /var/vagrant/lunr-virtualenv
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
      - file: /var/vagrant/lunr-virtualenv
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


##################
# Lunr / Cinder
################

install-lunr:
  cmd.run:
    - name: /usr/bin/install-lunr.py
    - creates: /var/vagrant/lunr-virtualenv/lib/python2.7/site-packages/lunr.egg-link
    - cwd: /
    - require:
      - file: /usr/bin/install-lunr.py
    - require_in:
      - service: service-lunr-screen
