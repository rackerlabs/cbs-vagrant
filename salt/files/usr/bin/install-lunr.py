#! /usr/bin/env python

import os

# Install lunr
os.chdir('/vagrant/lunr')
os.system("/opt/lunr-virtualenv/bin/pip install -r /vagrant/lunr/requirements.txt")
os.system('/opt/lunr-virtualenv/bin/python setup.py develop')
