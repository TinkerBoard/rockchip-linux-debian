#!/bin/bash -e

MMC=$(lsblk | grep "part /" | grep -v "/[a-z]" | awk -F ' ' '{print $1}' | awk -F 'p8' '{print $1}' | awk -F 'mmc' '{print $2}')
mount "/dev/mmc${MMC}p7" /boot/
