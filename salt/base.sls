
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

/usr/bin/setup-base.py:
  file.managed:
    - source: salt://files/usr/bin/setup-base.py
    - mode: 755

##################
# Setup Base
################

setup-base-vagrant:
  cmd.run:
    - name: /usr/bin/setup-base.py
    - user: vagrant
    - cwd: /home/vagrant
    - unless: ls /home/vagrant/.gitconfig

setup-base-root:
  cmd.run:
    - name: /usr/bin/setup-base.py
    - user: root
    - cwd: /root
    - unless: ls /root/.gitconfig

/usr/bin/bootstrap-pip.py:
  file.managed:
    - source: salt://files/usr/bin/bootstrap-pip.py
    - mode: 755
  cmd.run:
    - name: /usr/bin/bootstrap-pip.py
    - user: root
    - cwd: /tmp
    - reload_modules: true


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

