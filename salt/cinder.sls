
##################
# Packages
################

libxslt1-dev:
  pkg.installed: []

libxml2-dev:
  pkg.installed: []

rabbitmq-server:
  pkg.installed: []

libpq-dev:
  pkg.installed: []


##################
# Pip Packages
################

cinder-pip-packages:
  pip.installed:
    - requirements: /vagrant/cinder/requirements.txt
    - bin_env:  /opt/cinder-virtualenv
    - user: vagrant
    - require:
      - virtualenv: /opt/cinder-virtualenv
      - cmd: /usr/bin/bootstrap-pip.py
      - pkg: python-virtualenv
      - pkg: python-dev
      - pkg: libxml2-dev
      - pkg: libxslt1-dev

cinder-pip-test-packages:
  pip.installed:
    - requirements: /etc/cinder/test-requirements.txt
    - bin_env:  /opt/cinder-virtualenv
    - user: vagrant
    - require:
      - virtualenv: /opt/cinder-virtualenv
      - cmd: /usr/bin/bootstrap-pip.py
      - pkg: python-virtualenv
      - pkg: python-dev
      - pkg: libpq-dev

cinder-pip-mysql-packages:
  pip.installed:
    - name: mysql
    - bin_env:  /opt/cinder-virtualenv
    - user: vagrant
    - require:
      - virtualenv: /opt/cinder-virtualenv
      - cmd: /usr/bin/bootstrap-pip.py
      - pkg: python-virtualenv
      - pkg: python-dev
      - pkg: libmysqlclient-dev


##################
# Directories
################

/opt/cinder-virtualenv:
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
      - file: /opt/cinder-virtualenv

/var/log/cinder:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - mode: 755

/var/lib/cinder:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - mode: 755

/etc/cinder:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - recurse:
      - user
      - group

/etc/cinder/state:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - recurse:
      - user
      - group


##################
# Files
################

/home/vagrant/cinder-virtualenv:
  file.symlink:
    - target: /opt/cinder-virtualenv/bin/activate

/usr/bin/install-cinder.py:
  file.managed:
    - source: salt://files/usr/bin/install-cinder.py
    - mode: 755

/usr/bin/setup-cinder.py:
  file.managed:
    - source: salt://files/usr/bin/setup-cinder.py
    - mode: 755

/etc/cinder/policy.json:
  file.symlink:
    - target: /vagrant/cinder/etc/cinder/policy.json
    - user: vagrant
    - group: vagrant

/etc/cinder/api-paste.ini:
  file.symlink:
    - target: /vagrant/cinder/etc/cinder/api-paste.ini
    - user: vagrant
    - group: vagrant

/etc/cinder/cinder.conf:
  file.managed:
    - source: salt://files/etc/cinder/cinder.conf
    - mode: 644

/etc/cinder/test-requirements.txt:
  file.managed:
    - source: salt://files/etc/cinder/test-requirements.txt
    - mode: 644


##################
# Setup Cinder
################

install-cinder:
  cmd.run:
    - name: /usr/bin/install-cinder.py
    - creates: /opt/cinder-virtualenv/lib/python2.7/site-packages/cinder.egg-link
    - user: vagrant
    - cwd: /
    - require:
      - file: /usr/bin/install-cinder.py
      - virtualenv: /opt/cinder-virtualenv
      - pip: cinder-pip-packages
    - require_in:
      - service: service-lunr-screen

setup-cinder:
  cmd.run:
    - name: /usr/bin/setup-cinder.py
    - user: vagrant
    - cwd: /
    - unless: ls /opt/cinder-virtualenv/cinder-setup-complete
    - require:
      - pip: cinder-pip-packages
      - file: /usr/bin/setup-cinder.py
      - mysql_database: cinder-database
      - virtualenv: /opt/cinder-virtualenv

##################
# Misc
################

cinder-database:
  mysql_database.present:
    - name: cinder
    - require:
      - service: service-mysql

