#!/usr/bin/python3
"""Read the host-encrypted Bitwarden credential into memory, then drop privileges."""
import os
import pwd
import subprocess
import sys

key = subprocess.run(
    ['/usr/bin/systemd-creds', 'decrypt', '--name=homework-openrouter',
     '/etc/credstore.encrypted/homework-openrouter.cred', '-'],
    stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, check=False,
)
if key.returncode or not key.stdout:
    sys.exit('The encrypted OpenRouter credential is unavailable.')
os.environ['OPENROUTER_API_KEY'] = key.stdout.decode()
user = pwd.getpwnam('reidsurmeier')
os.initgroups(user.pw_name, user.pw_gid)
os.setgid(user.pw_gid)
os.setuid(user.pw_uid)
os.execv('/usr/bin/node', ['/usr/bin/node', '--experimental-strip-types', sys.argv[1]])
