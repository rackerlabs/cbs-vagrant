#! /usr/bin/env python

import os

# Install Cinder
os.chdir('/vagrant/cinder')
os.system("/opt/cinder-virtualenv/bin/pip install -r /etc/cinder/requirements.txt")
os.system('/opt/cinder-virtualenv/bin/python setup.py develop')

# Install lunrdriver
os.chdir('/vagrant/lunrdriver')
os.system("/opt/cinder-virtualenv/bin/python setup.py develop")

# Install Cinder Extensions
os.chdir('/vagrant/rackspace_cinder_extensions')
os.system("/opt/cinder-virtualenv/bin/python setup.py develop")
