#! /usr/bin/env python

import os

# Install Cinder
os.chdir('/vagrant/cinder')
os.system("/opt/cinder-virtualenv/bin/pip install -r /vagrant/cinder/requirements.txt")
os.system('/opt/cinder-virtualenv/bin/python setup.py develop')

# Install lunrdriver
os.chdir('/vagrant/lunrdriver')
#os.system("/opt/cinder-virtualenv/bin/pip install -r /vagrant/lunrdriver/requirements.txt")
os.system("/opt/cinder-virtualenv/bin/python setup.py develop")
