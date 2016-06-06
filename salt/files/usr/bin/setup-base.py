#! /usr/bin/env python

import os

# Install the python-lunrclient if user has it checked out
if os.path.exists("/vagrant/python-lunrclient/requirements.txt"):
    os.chdir('/vagrant/python-lunrclient')
    os.system("/opt/vagrant-virtualenv/bin/pip install -r requirements.txt")
    os.system("/opt/vagrant-virtualenv/bin/python setup.py develop")

# Install the python-cinderclient if user has it checked out
if os.path.exists("/vagrant/python-cinderclient/requirements.txt"):
    os.chdir('/vagrant/python-cinderclient')
    os.system("/opt/vagrant-virtualenv/bin/pip install -r requirements.txt")
    os.system("/opt/vagrant-virtualenv/bin/python setup.py develop")
else:
    os.system("/opt/vagrant-virtualenv/bin/pip install python-cinderclient")

# Install Hubble
os.system("/opt/vagrant-virtualenv/bin/pip install hubble")
