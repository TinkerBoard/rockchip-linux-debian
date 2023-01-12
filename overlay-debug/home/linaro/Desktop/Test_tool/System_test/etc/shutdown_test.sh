#!/bin/bash

### BEGIN INIT INFO
# Provides:          shutdown_test.sh
# Required-Start:    $all
# Required-Stop:     
# Should-Stop:       
# Default-Start:     2 3 4 5
# X-Start-Before:  
# Default-Stop:      
# Short-Description: Shutdown auto test tool
### END INIT INFO

times=$(grep -r "shutdown_times" /etc/shutdown_times.txt | awk '{print $3}')

log()
{
	timestamp="$(date +'%Y%m%d_%H%M')"
	logfile=/etc/pci_device.txt
	logfile2="/dev/kmsg"
	echo -e $1 | tee -a $logfile | sudo tee $logfile2
	logger -t shutdown_test "[$timestamp]$1"
}

case "$1" in
	start)
		((times+=1))
		sleep 60
		if [ "$times" = 1 ]; then
			SCRIPTPATH=`cat /etc/temp_script_path`
			CONFIGFILE=`cat /etc/temp_config_path`
			result=`sudo bash $SCRIPTPATH/scan_io.sh $CONFIGFILE | grep Fail`
			if [ -n "$result" ]; then
				echo $result >> /etc/shutdown_times.txt
				sudo update-rc.d -f shutdown_times.sh remove
				log "scan io fail"
				exit
			fi
		fi
		echo "shutdown_times = "$times | sudo tee /etc/shutdown_times.txt
		SCRIPTPATH=`cat /etc/temp_script_path`
		CONFIGFILE=`cat /etc/temp_config_path`
		result=`$SCRIPTPATH/check_io.sh $CONFIGFILE | grep Fail`
		if [ -n "$result" ]; then
			echo $result >> /etc/shutdown_times.txt
			sudo update-rc.d -f shutdown_test.sh remove
			log "check io fail"
			exit
		fi
		echo +40 > /sys/class/rtc/rtc0/wakealarm
		sync
		log "Call poweroff"
		#echo 1 | sudo tee /proc/sys/kernel/sysrq
		#echo o | sudo tee /proc/sysrq-trigger
		#sudo systemctl poweroff
		sudo poweroff -f
		;;
	stop)
		echo "Stopping shutdown_test"
		;;
	*)
		echo "Usage: /etc/init.d/shutdown_test.sh {start|stop}"
		exit 1
		;;
esac

exit 0
