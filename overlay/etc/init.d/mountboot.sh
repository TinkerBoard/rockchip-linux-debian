#!/bin/bash -e

MMC=$(lsblk | grep "part /" | grep -v "/[a-z]" | awk -F ' ' '{print $1}' | awk -F 'p9' '{print $1}' | awk -F 'mmc' '{print $2}')
mount "/dev/mmc${MMC}p8" /boot/
