#!/bin/bash -e

MMC=$(lsblk | grep "part /userdata" | awk -F ' ' '{print $1}' | awk -F 'mmcblk' '{new_var="mmcblk"$2;print new_var}')
mount "/dev/${MMC}" /boot/
