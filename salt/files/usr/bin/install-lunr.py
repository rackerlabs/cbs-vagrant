#! /usr/bin/env python

import os

os.chdir('/vagrant/lunr')
os.system('/opt/lunr-virtualenv/bin/python setup.py develop')

# Install the python-lunrclient if user has it checked out
if os.path.exists("/vagrant/python-lunrclient/requirements.txt"):
    os.chdir('/vagrant/python-lunrclient')
    os.system("/opt/lunr-virtualenv/bin/pip install -r /vagrant/python-lunrclient/requirements.txt")
    os.system("/opt/lunr-virtualenv/bin/python /vagrant/python-lunrclient/setup.py develop")

