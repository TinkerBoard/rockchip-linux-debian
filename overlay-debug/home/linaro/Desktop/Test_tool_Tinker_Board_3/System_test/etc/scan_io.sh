#!/bin/bash

LOG_PATH=/var/log/system_test
mkdir -p $LOG_PATH
LOG=${LOG_PATH}/exist_io
USB=${LOG_PATH}/exist_usb
PCI=${LOG_PATH}/exist_pci
rm -rf ${LOG_PATH}/*

log()
{
	timestamp="$(date +'%Y%m%d_%H%M')"
	logfile2="/dev/kmsg"
	echo -e $1 | sudo tee $logfile2
	logger -t scan_io "[$timestamp]$1"
}

scan_cpu()
{
	result=`nproc`
	if [ -n "$result" ]; then
		echo "$1 $result" >> $LOG
	else
		log "Fail, cpu core number error ($result)" | tee -a $RESULT
	fi
}

scan_ddr()
{
	result=`free -h | grep Mem | awk '{print $2}'`
	if [ -n "$result" ]; then
		echo "$1 $result" >> $LOG
	else
		log "Fail, ddr size error ($result)" | tee -a $RESULT
	fi
}

scan_iface()
{
	result=`ifconfig -a | grep $1`
	if [ -n "$result" ]; then
		echo $1 >> $LOG
	else
		log "Fail, $1 not exist" | tee -a $RESULT		
	fi
}

scan_blk()
{
	result=`lsblk | grep $2`
	if [ -n "$result" ]; then
		echo $1 >> $LOG
	else
		log "Fail, $1 not exist" | tee -a $RESULT
	fi
}

scan_msata()
{
	for i in `ls /sys/block/ | grep sd`
	do
		if [ `realpath /sys/block/$i | grep 38200000` ]; then
			if [ `cat /sys/block/$i/removable` == 0 ];then
				echo $1 >> $LOG
			fi
		fi
	done
}

scan_usb()
{
	result=`lsusb | awk '{print $5$6"-"$7$8}' | sudo tee $USB`
	if [ -n "$result" ]; then
		echo $1 >> $LOG
	else
		log "Fail, lose usb device" | tee -a $RESULT
	fi
}

scan_pci()
{
	result=`lspci | awk '{print $1"-"$2$3$4$5$6}' | sudo tee $PCI`
	if [ -n "$result" ]; then
		echo $1 >> $LOG
	else
		log "Fail, lose pci device" | tee -a $RESULT
	fi
}

scan_mcu()
{
	if [ $SOC_TYPE == "tegra" ]; then
		result=`mcu_system_test -v | grep "FW version" | awk '{print $5}'`
	elif [ $SOC_TYPE == "imx8" ]; then
		result=`system_test | grep version | awk '{print $5}'`
	fi 
	
	if [ -n "$result" ]; then
		echo "$1 $result" >> $LOG
	else
		log "Fail, lose mcu device" | tee -a $RESULT
	fi
}

scan_ssd_speed(){
	result="unknown"
	if [ $SOC_TYPE == "tegra" ]; then
		SOM=$(cat /sys/module/tegra_fuse/parameters/tegra_chip_id)
		# NX
		if [ "$SOM" == "25" ]; then
			result=`sudo lspci -s 0005:01:00.0 -vvv | grep -i "LnkSta:" | awk '{print $3}'`
		fi
		# NANO, TX2-NX
		if [ "$SOM" == "33" ] || [ "$SOM" == "24" ]; then 
			result=`sudo lspci -s 01:00.0 -vvv | grep -i "LnkSta:" | awk '{print $3}'`
		fi
	fi 
	
	if [ -n "$result" ]; then
		echo "$1 $result" >> $LOG
	else
		log "Fail, lose ssd device" | tee -a $RESULT
	fi
}

scan_aem_lan_speed(){
	result="unknown"
	if [ $SOC_TYPE == "tegra" ]; then
		SOM=$(cat /sys/module/tegra_fuse/parameters/tegra_chip_id)
		# NX
		if [ "$SOM" == "25" ]; then
			result=`sudo lspci -s 0005:03:00.0 -vvv | grep -i "LnkSta:" | awk '{print $3}'`
		fi
		# NANO, TX2-NX
		if [ "$SOM" == "33" ] || [ "$SOM" == "24" ]; then 
			result=`sudo lspci -s 03:00.0 -vvv | grep -i "LnkSta:" | awk '{print $3}'`
		fi
	fi 
	
	if [ -n "$result" ]; then
		echo "$1 $result" >> $LOG
	else
		log "Fail, lose aem_lan device" | tee -a $RESULT
	fi
}

if [ ! -z "$1" ]; then
   source $1
else
   echo "Need Config file"
   exit
fi

if [ "$CHECK_CPU" == "Y" ]; then
	scan_cpu cpu
fi
if [ "$CHECK_DDR" == "Y" ]; then
	scan_ddr ddr
fi
if [ "$CHECK_EMMC" == "Y" ]; then
	scan_blk emmc mmcblk0
fi
if [ "$CHECK_SD" == "Y" ]; then
	scan_blk sd mmcblk1
fi
if [ "$CHECK_MSATA" == "Y" ]; then
	scan_msata msata
fi
if [ "$CHECK_LAN0" == "Y" ]; then
	scan_iface eth0
fi
if [ "$CHECK_LAN1" == "Y" ]; then
	scan_iface eth1
fi
if [ "$CHECK_LAN2" == "Y" ]; then
	scan_iface eth2
fi
if [ "$CHECK_LAN3" == "Y" ]; then
	scan_iface eth3
fi
if [ "$CHECK_WIFI" == "Y" ]; then
	scan_iface wlan0
fi
if [ "$CHECK_CAN0" == "Y" ]; then
	scan_iface can0
fi
if [ "$CHECK_CAN1" == "Y" ]; then
	scan_iface can1
fi
if [ "$CHECK_USB" == "Y" ]; then
	scan_usb usb
fi
if [ "$CHECK_PCI" == "Y" ]; then
	scan_pci pci
fi
if [ "$CHECK_MCU" == "Y" ]; then
	scan_mcu mcu
fi
if [ "$CHECK_SSD" == "Y" ]; then
	scan_ssd_speed ssd
fi
if [ "$CHECK_AEM_LAN" == "Y" ]; then
	scan_aem_lan_speed aem-lan
fi
