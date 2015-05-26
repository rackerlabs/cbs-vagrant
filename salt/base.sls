
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

syslog-ng:
  pkg.installed: []

mysql-server:
  pkg.installed: []

mysql-client:
  pkg.installed: []

libmysqlclient-dev:
  pkg.installed: []

libssl-dev:
  pkg.installed: []

build-essential:
  pkg.installed: []

python-mysqldb:
  pkg.installed: []

devscripts:
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
# Files
################

/etc/syslog-ng/conf.d/cbs.conf:
  file.managed:
    - source: salt://files/etc/syslog-ng/conf.d/cbs.conf
    - template: jinja
    - require:
      - pkg: syslog-ng
    - watch_in:
      - service: service-syslog-ng

/etc/hosts:
  file.managed:
    - source: salt://files/etc/hosts

/usr/bin/setup-git.py:
  file.managed:
    - source: salt://files/usr/bin/setup-git.py
    - mode: 755

/opt/vagrant-virtualenv:
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
    - require:
      - file: /opt/vagrant-virtualenv
      - cmd: /usr/bin/bootstrap-pip.py


##################
# Setup Base
################

setup-git-vagrant:
  cmd.run:
    - name: /usr/bin/setup-git.py
    - user: vagrant
    - cwd: /home/vagrant
    - unless: ls /home/vagrant/.gitconfig

setup-git-root:
  cmd.run:
    - name: /usr/bin/setup-git.py
    - user: root
    - cwd: /root
    - unless: ls /root/.gitconfig

/usr/bin/setup-base.py:
  file.managed:
    - source: salt://files/usr/bin/setup-base.py
    - mode: 755
  cmd.run:
    - name: /usr/bin/setup-base.py
    - user: root
    - cwd: /root
    - require:
      - virtualenv: /opt/vagrant-virtualenv
      - file: /usr/bin/setup-base.py
      - cmd: /usr/bin/bootstrap-pip.py
    - unless: ls /opt/vagrant-virtualenv/bin/cinder

/usr/bin/bootstrap-pip.py:
  file.managed:
    - source: salt://files/usr/bin/bootstrap-pip.py
    - mode: 755
  cmd.run:
    - name: /usr/bin/bootstrap-pip.py
    - user: root
    - cwd: /tmp
    - unless: /usr/bin/bootstrap-pip.py --check
    - reload_modules: true
    - require:
      - pkg: python-dev
      - pkg: python-pip
      - pkg: build-essential
      - pkg: libssl-dev
      - pkg: libffi-dev
      - file: /usr/bin/bootstrap-pip.py


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

service-mysql:
  service.running:
    - name: mysql
    - require:
      - pkg: mysql-server

##################
# User Groups
################
vagrant:
  user.present:
    - groups:
      - sudo
      - adm
      - disk
