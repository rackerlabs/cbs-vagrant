#! /usr/bin/env python

import os

os.chdir('/vagrant/lunr')
os.system('/var/vagrant/lunr-virtualenv/bin/python setup.py develop')
