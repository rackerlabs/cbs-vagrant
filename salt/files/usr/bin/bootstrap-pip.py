#! /usr/bin/env python

from subprocess import check_output
import os
import re


def compare_versions(version1, version2):
    def normalize(v):
        return [int(x) for x in re.sub(r'(\.0+)*$','', v).split(".")]
    return cmp(normalize(version1), normalize(version2))

# Setup pip if old version
version = check_output('pip --version', shell=True).split(' ')[1]
if compare_versions(version, '6.1.1') == -1:
    os.chdir('/tmp')
    os.system('curl -O https://bootstrap.pypa.io/get-pip.py')
    os.system('python get-pip.py')
    os.system('pip install distribute --upgrade')
    os.system('pip install setuptools --upgrade')
    os.system('pip install pbr --upgrade')

