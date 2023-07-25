#!/bin/bash

RESULT=/var/log/system_test/result
LOG=/var/log/system_test/exist_io
USB=/var/log/system_test/exist_usb
TMP_USB=/var/log/system_test/tmp_usb
PCI=/var/log/system_test/exist_pci
TMP_PCI=/var/log/system_test/tmp_pci
exist_io=`cat $LOG`

rm -rf $RESULT

log()
{
	timestamp="$(date +'%Y%m%d_%H%M')"
	logfile2="/dev/kmsg"
	echo -e $1 | sudo tee $logfile2
	logger -t check_io "[$timestamp]$1"
}

check_cpu()
{
	result=`nproc`
	if [ "$1" = "$result" ]; then
		echo "Pass, cpu core number correct ($result)" | tee -a $RESULT
	else
		echo "Fail, cpu core number error ($result)" | tee -a $RESULT
	fi
}

check_ddr()
{
	result=`free -h | grep Mem | awk '{print $2}'`
	if [ "$1" = "$result" ]; then
		echo "Pass, ddr size correct ($result)" | tee -a $RESULT
	else
		echo "Fail, ddr size error ($result)" | tee -a $RESULT
	fi
}

check_iface()
{
	result=`ifconfig -a | grep $1`

	if [ -n "$result" ]; then
		echo "Pass, $1 exist" | tee -a $RESULT
	else
		echo "Fail, $1 not exist" | tee -a $RESULT
	fi
}

check_blk()
{
	if [ "$1" == emmc ]; then
		result=`lsblk | grep mmcblk0`

	elif [ "$1" == sd ]; then
		result=`lsblk | grep mmcblk1`
	fi

	if [ -n "$result" ]; then
		echo "Pass, $1 exist" | tee -a $RESULT
	else
		echo "Fail, $1 not exist" | tee -a $RESULT
	fi
}

check_msata()
{
	for i in `ls /sys/block/ | grep sd`
	do
		if [ `realpath /sys/block/$i | grep 38200000` ]; then
			if [ `cat /sys/block/$i/removable` == 0 ];then
				echo "Pass, $1 exist" | tee -a $RESULT
				exit
			fi
		fi
	done
	echo "Fail, $1 not exist" | tee -a $RESULT
}

check_usb()
{
	result=`lsusb | awk '{print $5$6"-"$7$8}' | sudo tee $TMP_USB`
	if [ -n "$result" ]; then
		usb_cnt=`cat $USB | wc -l`
		tmp_usb_cnt=`cat $TMP_USB | wc -l`
		echo "usb_cnt=$usb_cnt, tmp_usb_cnt=$tmp_usb_cnt"
		if [ "$usb_cnt" != "$tmp_usb_cnt" ]; then
			echo "Fail, lose usb device" | tee -a $RESULT
		fi

		for sub_usb in `cat $USB`
		do
			usb_flag=$( cat $TMP_USB | grep "$sub_usb" | grep -v "grep")
			if [ "$usb_flag" == ""  ]
			then
				log "Fail, usb device $sub_usb not found!"
				echo "Fail, usb device $sub_usb not found! " | tee -a $RESULT
			else
				echo "Pass, usb device $sub_usb found" | tee -a $RESULT
			fi
		done
	fi
}

check_pci()
{
	result=`lspci | awk '{print $1"-"$2$3$4$5$6}' | sudo tee $TMP_PCI`
	if [ -n "$result" ]; then
		pci_cnt=`cat $PCI | wc -l`
		tmp_pci_cnt=`cat $TMP_PCI | wc -l`
		echo "pci_cnt=$pci_cnt, tmp_pci_cnt=$tmp_pci_cnt"
		if [ "$pci_cnt" != "$tmp_pci_cnt" ]; then
			echo "Fail, lose pci device" | tee -a $RESULT
		fi

		for sub_pci in `cat $PCI`
		do	
			pci_flag=$( cat $TMP_PCI | grep "$sub_pci" | grep -v "grep")
			if [ "$pci_flag" == ""  ]
			then
				log "Fail, pci device $sub_pci not found!"
				echo "Fail, pci device $sub_pci not found! " | tee -a $RESULT
			else
				echo "Pass, pci device $sub_pci found" | tee -a $RESULT
			fi
		done
	fi
}

check_mcu()
{
	if [ $SOC_TYPE == "tegra" ]; then
		result=`mcu_system_test -v | grep "FW version" | awk '{print $5}'`
	elif [ $SOC_TYPE == "imx8" ]; then
		result=`system_test | grep version | awk '{print $5}'`
	fi 

	if [ "$1" = "$result" ]; then
		echo "Pass, get mcu ver successfully ($result)" | tee -a $RESULT
	else
		echo "Fail, get wrong mcu ver ($result)" | tee -a $RESULT
	fi
}

check_ssd_speed()
{
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

	if [ "$1" = "$result" ]; then
		echo "Pass, check SSD speed successfully ($result)" | tee -a $RESULT
	else
		echo "Fail, get wrong SSD speed ($result)" | tee -a $RESULT
	fi
}

check_aem_lan_speed()
{
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

	if [ "$1" = "$result" ]; then
		echo "Pass, check AEM-LAN speed successfully ($result)" | tee -a $RESULT
	else
		echo "Fail, get wrong AEM-LAN speed ($result)" | tee -a $RESULT
	fi
}

echo $1

if [ ! -z "$1" ]; then
   source $1
else
   echo "Need Config file"
   exit
fi



for io in $exist_io
do

	if [ "$find_cpu" == 1 ]; then
		find_cpu=0
		check_cpu $io
	fi

	if [ "$find_ddr" == 1 ]; then
		find_ddr=0
		check_ddr $io
	fi

	if [ "$find_mcu" == 1 ]; then
		find_mcu=0
		check_mcu $io
	fi

	if [ "$find_ssd_speed" == 1 ]; then
		find_ssd_speed=0
		check_ssd_speed $io
	fi
	
	if [ "$find_aem_lan_speed" == 1 ]; then
		find_aem_lan_speed=0
		check_aem_lan_speed $io
	fi

	if [ "$io" == eth0 -o "$io" == eth1 -o "$io" == eth2 -o "$io" == eth3 -o "$io" == wlan0 -o "$io" == can0 -o "$io" == can1 ]; then
		check_iface $io
	elif [ "$io" == sd -o "$io" == emmc ]; then
		check_blk $io
	elif [ "$io" == msata ]; then
		check_msata $io
	elif [ "$io" == usb ]; then
		check_usb $io
	elif [ "$io" == pci ]; then
		check_pci $io
	elif [ "$io" == cpu ]; then
		find_cpu=1
	elif [ "$io" == ddr ]; then
		find_ddr=1
	elif [ "$io" == mcu ]; then
		find_mcu=1
	elif [ "$io" == ssd ]; then
		find_ssd_speed=1
	elif [ "$io" == aem-lan ]; then
		find_aem_lan_speed=1
	fi

done

