#! /usr/bin/env python

from requests.exceptions import ConnectionError

import requests
import time
import sys
import os


# Run setup of lunr database tables
os.system("/opt/cinder-virtualenv/bin/cinder-manage db sync")
os.system("touch /opt/cinder-virtualenv/cinder-setup-complete")

