#! /usr/bin/env python

from requests.exceptions import ConnectionError

import requests
import time
import sys
import os


def waitFor(url):
  for i in range(1, 10):
    try:
      return requests.get(url)
    except ConnectionError:
      sys.stdout.write(".")
      sys.stdout.flush()
      pass
    time.sleep(1)
  sys.stdout.write('\n')

# Run setup of lunr database tables
os.system("/var/vagrant/lunr-virtualenv/bin/lunr-manage version_control 2> /dev/null")
os.system("/var/vagrant/lunr-virtualenv/bin/lunr-manage upgrade")

# Start the services
os.system("/usr/sbin/service lunr-screen start")

# Create the volume type
waitFor("http://localhost:8081/status")
os.system("/var/vagrant/lunr-virtualenv/bin/lunr-admin type create vtype")
os.system("/usr/sbin/service lunr-screen restart")

# Deploy all available nodes
waitFor("http://localhost:8081/status")
os.system("/var/vagrant/lunr-virtualenv/bin/lunr-admin node deploy -a")
os.system("/usr/sbin/service lunr-screen restart")

