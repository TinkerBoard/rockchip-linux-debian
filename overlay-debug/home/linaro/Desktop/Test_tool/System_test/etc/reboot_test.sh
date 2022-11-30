#!/bin/bash

### BEGIN INIT INFO
# Provides:          reboot_test.sh
# Required-Start:    $all
# Required-Stop:     
# Should-Stop:       
# Default-Start:     2 3 4 5
# X-Start-Before:  
# Default-Stop:      
# Short-Description: Reboot auto test tool
### END INIT INFO

times=$(grep -r "reboot_times" /etc/reboot_times.txt | awk '{print $3}')
#SOM identification
#25 (xavier -NX)
#33 (Nano)
#24 (TX2 -NX)
SOM=$(cat /sys/module/tegra_fuse/parameters/tegra_chip_id)
SOC_TYPE=`cat /etc/soc_type.txt`
echo "SOM id: $SOM"
bChange=0
sleep_time=40

log()
{
	timestamp="$(date +'%Y%m%d_%H%M')"
	logfile=/etc/pci_device.txt
	logfile2="/dev/kmsg"
	echo -e $1 | tee -a $logfile | sudo tee $logfile2
	logger -t reboot_test "[$timestamp]$1"
}

check_pci_device()
{
	if [ "$1" == "33" ]; then 
		pci_device=$(lspci | grep "01:00")
		slot=$(sudo ex_gpio -m | grep switch | awk '{print $5}')
		log "Detect Now is M.2 $slot"
		if [ ! -z "$pci_device" ]; then
			log "test times:$times $pci_device"
		else
			log "FAIL: no device"
		fi
	fi
	
	if [ "$1" == "25" ] || [ "$1" == "24" ]; then
		pci_device1=$(lspci | grep "01:00")
		pci_device2=$(lspci | grep "02:00")
		if [ ! -z "$pci_device1" ] && [ ! -z "$pci_device2" ]; then
			log "test times:$times $pci_device1 , $pci_device2"
		else
			log "FAIL: loss device, $pci_device1 , $pci_device2"
		fi
	fi 

}

changing_pci_device()
{
	case $slot in
	'E')
		which_device=$(echo $pci_device | grep "Network controller")
	    if [ -z "$which_device" ]; then
			log "FAIL: is not WiFi"
		fi 
		log "Now is M.2 $slot and will change to M.2 M"
		sudo ex_gpio -m m.2m > /dev/null 2>&1
		slot_c=$(sudo ex_gpio -m | grep switch | awk '{print $5}')
		log "Now change to  M.2 $slot_c"
		;;
	'M')
		which_device=$(echo $pci_device | grep "Non-Volatile memory controller")
	    if [ -z "$which_device" ]; then
			log "FAIL: is not SSD"
		fi 
		log "Now is M.2 $slot and will change to M.2 E"
		sudo ex_gpio -m m.2e > /dev/null 2>&1
		slot_c=$(sudo ex_gpio -m | grep switch | awk '{print $5}')
		log "Now change to M.2 $slot_c"		;;
	esac
}


case "$1" in
	start)
		((times+=1))
		log "reboot_times = "$times | sudo tee /etc/reboot_times.txt
		if [ "$times" = 1 ]; then
			SCRIPTPATH=`cat /etc/temp_script_path`
			CONFIGFILE=`cat /etc/temp_config_path`
			result=`sudo bash $SCRIPTPATH/scan_io.sh $CONFIGFILE | grep Fail`
			if [ -n "$result" ]; then
				echo $result >> /etc/reboot_times.txt
				sudo update-rc.d -f reboot_test.sh remove
				log "scan io fail"
				exit
			fi
		fi
		if [ "$SOC_TYPE" == "tegra" ]; then
			if [ "$SOM" == "33" ] || [ "$SOM" == "25" ] || [ "$SOM" == "24" ]; then
				check_pci_device $SOM
			fi
			sleep $sleep_time
			if [ "$SOM" == "33" ] && [ $bChange == 1 ]; then
				changing_pci_device
			fi
		else
			sleep $sleep_time
		fi

		SCRIPTPATH=`cat /etc/temp_script_path`
		CONFIGFILE=`cat /etc/temp_config_path`
		result=`$SCRIPTPATH/check_io.sh $CONFIGFILE | grep Fail`
		if [ -n "$result" ]; then
			echo $result >> /etc/reboot_times.txt
			sudo update-rc.d -f reboot_test.sh remove
			log "check io fail"
			exit
		fi
		sync
#		echo 1 | sudo tee /proc/sys/kernel/sysrq
#		echo b | sudo tee /proc/sysrq-trigger
		log "Call reboot"
		systemctl reboot
		;;
	stop)
		echo "Stopping reboot_test"
		;;
	*)
		echo "Usage: /etc/init.d/reboot_test.sh {start|stop}"
		exit 1
		;;
esac

exit 0
