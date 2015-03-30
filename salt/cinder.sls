

##################
# Directories
################

/var/log/cinder:
  file.directory:
    - user: vagrant
    - group: vagrant
    - makedirs: True
    - mode: 755


##################
# Files
################

/home/vagrant/cinder-virtualenv:
  file.symlink:
    - target: /opt/cinder-virtualenv/bin/activate


##################
# Misc
################

cinder-database:
  mysql_database.present:
    - name: cinder
    - require:
      - service: service-mysql
