#!/bin/bash

uboot_path=/home/linaro/Desktop/factory_tools/files/uboot

if [ "$#" == 1 ]; then
	if [ "$1" == "spi" ]; then
		dev=/dev/mtdblock0
		spl_img=$uboot_path/spinor_spl.img
		uboot_img=$uboot_path/uboot.img

		lsblk | grep mtdblock0
		[ $? -eq 0 ] || { echo "No SPI Flash"; exit -1; }
		[ -f $spl_img ] || { echo "$spl_img unfound"; exit -1; }
		[ -f $uboot_img ] || { echo "$uboot_img unfound"; exit -1; }

		spl_size=$(ls -al $spl_img | awk '{print $5}')
		spl_size_BK=$(($spl_size/512))
		uboot_size=$(ls -al $uboot_img | awk '{print $5}')
		uboot_size_BK=$(($uboot_size/512))

		echo "Erase SPI Flash"
		sudo mtd_debug erase /dev/mtd0 0 0x01000000
		echo "Flash U-Boot SPL to SPI Flash"
		sudo dd if=$spl_img of=$dev
		sync
		sudo dd if=$dev of=$spl_img.bak count=$spl_size_BK conv=noerror,sync
		old_file_hash=$(md5sum $spl_img | cut -d ' ' -f 1)
		new_file_hash=$(md5sum $spl_img.bak | cut -d ' ' -f 1)
		rm -rf $spl_img.bak
		if [ "${old_file_hash}" == "${new_file_hash}" ]; then
			echo "U-Boot SPL PASS"
		else
			echo "U-Boot SPL FAIL"
		fi

		echo "Flash U-Boot to SPI Flash"
		sudo dd if=$uboot_img of=$dev seek=16384
		sync
		sudo dd if=$dev of=$uboot_img.bak skip=16384 count=$uboot_size_BK conv=noerror,sync
		old_file_hash=$(md5sum $uboot_img | cut -d ' ' -f 1)
		new_file_hash=$(md5sum $uboot_img.bak | cut -d ' ' -f 1)
		rm -rf $uboot_img.bak
		if [ "${old_file_hash}" == "${new_file_hash}" ]; then
			echo "U-Boot PASS"
		else
			echo "U-Boot FAIL"
		fi
	elif [ "$1" == "emmc" ]; then
		dev=/dev/mmcblk0
		uboot_img=$uboot_path/sdcard_uboot.img

		lsblk | grep mmcblk0
		[ $? -eq 0 ] || { echo "No eMMC"; exit -1; }
		[ -f $uboot_img ] || { echo "$uboot_img unfound"; exit -1; }

		uboot_size=$(ls -al $uboot_img | awk '{print $5}')
		uboot_size_MB=$(($uboot_size/1048576))

		echo "Flash U-Boot to eMMC"
		sudo dd if=$uboot_img of=$dev
		sync
		sudo dd if=$dev of=$uboot_img.bak bs=1M count=$uboot_size_MB conv=noerror,sync
		old_file_hash=$(md5sum $uboot_img | cut -d ' ' -f 1)
		new_file_hash=$(md5sum $uboot_img.bak | cut -d ' ' -f 1)
		rm -rf $uboot_img.bak
		if [ "${old_file_hash}" == "${new_file_hash}" ]; then
			echo "PASS"
		else
			echo "FAIL"
		fi
	else
		echo "usage: ./flash_uboot.sh [emmc/spi]"
		exit -1
	fi
else
	echo "usage: ./flash_uboot.sh [emmc/spi]"
	exit -1
fi
