#! /usr/bin/env python

from requests.exceptions import ConnectionError

import requests
import time
import os


def waitFor(url):
    for i in range(1, 10):
        try:
            return requests.get(url)
        except ConnectionError:
            pass
        time.sleep(1)

# Run setup of lunr database tables
os.system("/opt/lunr-virtualenv/bin/lunr-manage version_control")
os.system("/opt/lunr-virtualenv/bin/lunr-manage upgrade")

# Start the services
os.system("/usr/sbin/service lunr-screen start")

# Create the volume type
waitFor("http://localhost:8081/status")
os.system("/opt/lunr-virtualenv/bin/lunr-admin type create vtype")
os.system("/usr/sbin/service lunr-screen restart")

# Service still be running (give service time to stop and start)
time.sleep(2)

# Deploy all available nodes
waitFor("http://localhost:8081/status")
os.system("/opt/lunr-virtualenv/bin/lunr-admin node deploy -a")
os.system("/usr/sbin/service lunr-screen stop")

if os.path.exists("/vagrant/python-lunrclient/requirements.txt"):
    os.chdir('/vagrant/python-lunrclient')
    os.system("/opt/lunr-virtualenv/bin/pip install -r requirements.txt")
    os.system("/opt/lunr-virtualenv/bin/python setup.py develop")
