#!/usr/bin/env python3

MAGIC_WORD='from https://api.fastly.com/public-ip-list'

import subprocess
import pprint

def main():
    ufw_process = subprocess.run(['sudo', 'ufw', 'status', 'numbered'], check=True, shell=False, stdout=subprocess.PIPE)
    ufw_status_old = ufw_process.stdout.splitlines()
    pprint.pprint(ufw_status_old)

if __name__ == '__main__':
  main()
