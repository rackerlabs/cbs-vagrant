#!/usr/bin/env python
# Copyright (c) 2011-2013 Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from os.path import abspath, join, dirname, basename
from tempfile import NamedTemporaryFile
from stat import S_IRUSR, S_IRGRP
from optparse import OptionParser
from shutil import move

import subprocess
import grp
import os
import pwd
import sys
import re


def get_devices():
    devices = {}
    stdout, stderr = subprocess.Popen(['fdisk', '-l'], stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE).communicate()

    # fdisk spits out partitioned devices to stdout
    for line in stdout.splitlines():
        if 'Disk /' in line:
            # Split 'Disk /dev/sda: 80.0 GB, 80000000000 bytes'
            values = line.split()
            # devices = { '/dev/sda': { 'size': '80.0 GB' ....  } }
            devices[values[1].strip(':')] = {'size': " ".join(values[2:3]),
                                             'bytes': values[4],
                                             'partitioned': True,
                                             'lvm': False}

    # fdisk spits out un-partitioned devices to stderr
    for line in stderr.splitlines():
        # Split 'Disk /dev/sdb doesn't contain a valid partition table'
        devices[line.split(None, 2)[1]]['partitioned'] = False

    stdout, stderr = subprocess.Popen(['pvs', '--noheadings',
                                      '--options=pv_name'],
                                      stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE).communicate()

    # 'pvs' will display all physical volumes that are registered with LVM
    for line in stdout.splitlines():
        try:
            devices[line.strip()]['lvm'] = True
        except KeyError:
            pass

    return devices


def get_pvname(options):

    # Get a list of devices on the system
    devices = get_devices()

    # Find the device we are looking for
    for disk, info in sorted(devices.items()):
        if disk == options.device:
            return disk

    raise RuntimeError("Requested device '%s' not found" % options.device)


def yes_no(msg, default=None):
    while True:
        result = raw_input(msg)
        if default:
            if result == "":
                return default
        if re.match("^(Y|y)$", result):
            return True
        if re.match("^(N|n)$", result):
            return False


def parse_sudoers(file, user):
    variable_name = ''
    # add lunr_sudoers to /etc/sudoers.d/
    lunr_sudoers = []
    with open(file) as f:
        for line in f:
            if not line:
                continue
            lunr_sudoers.append(line)
        # mangle last line
        lunr_sudoers[-1] = lunr_sudoers[-1].replace('lunr', user, 1)
        # Get the name of the variable at the
        # end of this line (ie: LUNRCMDS)
        variable_name = lunr_sudoers[-1].split()[-1]

    with NamedTemporaryFile(delete=False) as f:
        f.writelines(lunr_sudoers)
        tmp_path = f.name

    os.chmod(tmp_path, S_IRUSR | S_IRGRP)  # 0440
    # Remove the -sample from 'lunr_sudoers-sample', then give it a new path
    move(tmp_path, join('/etc/sudoers.d', basename(file.split('-')[0])))
    return variable_name


def main():
    parser = OptionParser('%prog [OPTIONS] [PVNAME]')
    parser.add_option('--volume-group', default='lunr-volume',
                      help='set lvm volume group name')
    parser.add_option('--ietd-config', default='/etc/iet/ietd.conf',
                      help='set path to ietd.conf')
    parser.add_option('--user', default='vagrant',
                      help='set the user (and group) that will run the '
                      'storage server')
    parser.add_option('--device', default='/dev/sdb',
                      help='physical disk used for lunr-volume')
    parser.add_option('--group', default='vagrant',
                      help='over-ride group to be different that user')
    parser.add_option('--no-lvm', dest='lvm', default=True,
                      action='store_false', help='skip lvm commands')
    parser.add_option('--lvm-only', dest='lvm_only', action='store_true',
                      help='only do lvm setup')
    options, args = parser.parse_args()

    if os.getuid():
        parser.print_help()
        print
        return 'ERROR: %s must be run as root or with sudo.' % sys.argv[0]

    if not options.user:
        return 'ERROR: must provide --user option'

    if not options.group:
        options.group = options.user

    if not options.lvm_only:
        try:
            pwd.getpwnam(options.user)
        except KeyError:
            return 'ERROR: invalid user %s' % options.user

        try:
            grp.getgrnam(options.group)
        except KeyError:
            return 'ERROR: invalid group %s' % options.group

    # TODO:(thrawn01) figure out which isci backend we are
    # using and run setup for that backend

    commands = """
usermod -a -G disk %(user)s
touch %(ietd_config)s
chgrp %(group)s %(ietd_config)s
chmod g+w %(ietd_config)s
""".strip().splitlines()

    lvm_commands = """
pvcreate %(pvname)s --metadatasize=1024k
vgcreate %(volume_group)s %(pvname)s
""".strip().splitlines()

    subs = dict(vars(options))

    if options.lvm or options.lvm_only:
        # check for existing volume group
        with open(os.devnull, 'w') as f:
            returncode = subprocess.call(('vgs', options.volume_group),
                                         stdout=f, stderr=f)
        if returncode:
            pvname = get_pvname(options)

            # add lvm setup commands
            if options.lvm_only:
                commands = lvm_commands
            else:
                commands.extend(lvm_commands)
            subs['pvname'] = pvname
        else:
            print ('A volume group named %s already exists.' %
                   options.volume_group)

    # put it back together, sub in options and break it back apart
    commands = (os.linesep.join(commands) % subs).strip().splitlines()

    for cmd in commands:
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
        out, err = p.communicate()
        print 'COMMAND: %s' % cmd
        if p.returncode:
            if out:
                print 'STDOUT: %s' % out
            if err:
                print 'STDERR: %s' % err
            return 'ERROR: command failed with errcode %s' % p.returncode

    return 0


if __name__ == "__main__":
    sys.exit(main())
