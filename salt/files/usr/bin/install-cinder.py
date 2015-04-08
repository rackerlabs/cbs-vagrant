#! /usr/bin/env python

import os

os.chdir('/vagrant/cinder')
os.system('/opt/cinder-virtualenv/bin/python setup.py develop')

# Install the python-cinderclient if user has it checked out
if os.path.exists("/vagrant/python-cinderclient/requirements.txt"):
    os.chdir('/vagrant/python-cinderclient')
    os.system("/opt/cinder-virtualenv/bin/pip install -r /vagrant/python-cinderclient/requirements.txt")
    os.system("/opt/cinder-virtualenv/bin/python /vagrant/python-cinderclient/setup.py develop")

