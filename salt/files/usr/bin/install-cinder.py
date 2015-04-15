#! /usr/bin/env python

import os

os.chdir('/vagrant/cinder')
os.system('/opt/cinder-virtualenv/bin/python setup.py develop')

# Install the python-cinderclient if user has it checked out
if os.path.exists("/vagrant/python-cinderclient/requirements.txt"):
    os.chdir('/vagrant/python-cinderclient')
    os.system("/opt/cinder-virtualenv/bin/pip install -r requirements.txt")
    os.system("/opt/cinder-virtualenv/bin/python setup.py develop")
else:
    os.system("/opt/cinder-virtualenv/bin/pip install python-cinderclient")

# Install the python-lunrclient if user has it checked out
if os.path.exists("/vagrant/python-lunrclient/requirements.txt"):
    os.chdir('/vagrant/python-lunrclient')
    os.system("/opt/cinder-virtualenv/bin/pip install -r requirements.txt")
    os.system("/opt/cinder-virtualenv/bin/python setup.py develop")

# Install lunrdriver
os.chdir('/vagrant/lunrdriver')
os.system("/opt/cinder-virtualenv/bin/python setup.py develop")

# Install the spoofstone
if os.path.exists("/vagrant/spoofstone"):
    os.system("/usr/bin/python /vagrant/spoofstone/setup.py develop")

# Install Hubble
os.system("/opt/cinder-virtualenv/bin/pip install git+https://github.com/thrawn01/hubble.git@master")
