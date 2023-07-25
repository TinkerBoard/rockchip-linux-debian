#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
# MIT License
# Copyright (c) 2017-2018 Jetsonhacks
# Please see accompanying license information
from __future__ import print_function
import os,sys
import re
__all__ = [
    'name',
    'model',
    'compatible_models',
    'dts_filename',
    'soc',
    'nickname',
]

def cat(filename):
    with open(filename) as f:
        return f.read().rstrip('\x00')

def name():
    return cat('/proc/device-tree/model')

#def model():
#    return cat('/proc/device-tree/nvidia,proc-boardid')
def chipid():
    raw = cat ('/sys/module/tegra_fuse/parameters/tegra_chip_id')
    return raw.rstrip('\r\n')

def chipuid():
    raw = cat ('/sys/module/tegra_fuse/parameters/tegra_chip_uid')
    return raw.rstrip('\r\n')

def compatible_models():
    raw = cat('/proc/device-tree/compatible')
    return re.split(r'nvidia|\x00|,|\+', raw)[2:4]

def dts_filename(short=False):
    if short:
        return os.path.basename(dts_filename())
    return os.path.abspath(cat('/proc/device-tree/nvidia,dtsfilename'))

def soc(short=False):
    if short:
         return re.search(r'(?<=platform/)(.*)(?=kernel-dts)', dts_filename())[0].split('/')[0]
    raw = cat('/proc/device-tree/compatible')
    return re.split(r'nvidia|\x00|,|\+', raw)[9]

def nickname():
    return re.search(r'(?<=platform/)(.*)(?=kernel-dts)', dts_filename())[0].split('/')[1]

def quick_test():
    print(f'name={name()}')
    #print(f'model={model()}')
    print(f'compatible_models={compatible_models()}' )
    print(f'dts_filename={dts_filename()}')
    print(f'dts_filename_short={dts_filename(short=True)}')
    print(f'soc={soc()}')
    print(f'short_soc={soc(short=True)}')
    print(f'nickname={nickname()}')
    print(f'chipuid={chipuid()}')
    print(f'chipid={chipid()}')
    
class terminalColors:
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

import pprint
import subprocess

command = ['bash', '-c', 'source scripts/jetson_variables.sh && env']

proc = subprocess.Popen(command, stdout = subprocess.PIPE)
environment_vars = {}
for line in proc.stdout:
  (key, _, value) = line.partition(b"=")
  environment_vars[key.decode()] = value.decode()

proc.communicate() 

# Jetson Model
print("NVIDIA Jetson " + environment_vars["JETSON_TYPE"].strip())

#L4T Version
print(' L4T ' + environment_vars['JETSON_L4T'].strip() + ' [ JetPack ' +environment_vars['JETSON_JETPACK'].strip()+' ]')
# Ubuntu version
if os.path.exists('/etc/os-release'):
    with open('/etc/os-release', 'r') as ubuntuVersionFile:
        ubuntuVersionFileText=ubuntuVersionFile.read()
    for line in ubuntuVersionFileText.splitlines(): 
        if 'PRETTY_NAME' in line: 
            # PRETTY_NAME="Ubuntu 16.04 LTS"
            ubuntuRelease=line.split('"')[1]
            print('   ' + ubuntuRelease)       
else:
    print(terminalColors.FAIL + 'Error: Unable to find Ubuntu Version'  + terminalColors.ENDC)
    print('Reason: Unable to find file /etc/os-release')

# Kernel Release
if os.path.exists('/proc/version'):
    with open('/proc/version', 'r') as versionFile:
        versionFileText=versionFile.read()
    kernelReleaseArray=versionFileText.split(' ')
    print('   Kernel Version: ' + kernelReleaseArray[2])
else:
    print(terminalColors.FAIL + 'Error: Unable to find Linux kernel version'  + terminalColors.ENDC)
    print('Reason: Unable to find file /proc/version')


command1 = ['bash', '-c', 'source scripts/jetson_libraries.sh && env']

proc1 = subprocess.Popen(command1, stdout = subprocess.PIPE)
# environment_vars = {}
for line in proc1.stdout:
  (key, _, value) = line.partition(b"=")
  environment_vars[key.decode()] = value.decode()


if __name__ == "__main__":
    print(' CUDA ' + environment_vars['JETSON_CUDA'].strip())
    print('   CUDA Architecture: ' + environment_vars['JETSON_CUDA_ARCH_BIN'].strip())
    print(' OpenCV version: ' + environment_vars['JETSON_OPENCV'].strip())
    print('   OpenCV Cuda: ' + environment_vars['JETSON_OPENCV_CUDA'].strip())
    print(' CUDNN: ' + environment_vars['JETSON_CUDNN'].strip())
    print(' TensorRT: ' + environment_vars['JETSON_TENSORRT'].strip())
    print(' Vision Works: ' + environment_vars['JETSON_VISIONWORKS'].strip())
    print(' VPI: ' + environment_vars['JETSON_VPI'].strip())
    print(' Vulcan: ' + environment_vars['JETSON_VULKAN_INFO'].strip())
    quick_test()

