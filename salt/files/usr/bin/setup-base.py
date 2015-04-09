#! /usr/bin/env python

from requests.exceptions import ConnectionError

import requests
import time
import sys
import os

# Setup github color things
os.system('git config --global color.diff auto')
os.system('git config --global color.status auto')
os.system('git config --global color.branch auto')

