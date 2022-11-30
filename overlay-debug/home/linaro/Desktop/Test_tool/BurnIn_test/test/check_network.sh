#!/bin/bash

sleep 5
err_cnt=0
err_cnt2=0
logfile=$1

log()
{
	start_time="$(date +'%Y/%m/%d/%H:%M:%S')"
	echo -e $start_time "check_network " $1 | sudo tee -a $logfile
}

while [ 1 != 2 ]
do
	
	#usblan=`lsusb | grep 0bda:8153`
	#log "usblan: $usblan"
	#if [ -z "$usblan" ]; then
	#	log "usb lan was loss"
	#	exit
	#if dmesg -T | grep "usb 2-2.4: USB disconnect" > /dev/null
	if dmesg -T | grep "xhci: HC died" > /dev/null
	then
		log "detect USB contoller hang"
		err_cnt=0
		err_cnt2=0
		sleep 60
	else
		ipresults=`ip netns | grep ns_server`
		#log "ip results: $ipresults"
		if [ ! -z "$ipresults" ] ; then
			if ip netns exec ns_server ping -c 3 -W 2 192.168.100.99 &> /dev/null
			then
				err_cnt=0
				log "ping 192.168.100.99 pass"
			else
				((err_cnt+=1))
				log "ping -c 1 192.168.100.99 fail [$err_cnt]"
			fi
		
			if [ $err_cnt -gt 120 ] || [ $err_cnt2 -gt 120 ] ; then
				log "error is more than 120 times"
				break
			fi
			
		else
	       		log "ip was delete"
			err_cnt=0
			err_cnt2=0
			sleep 60
		fi
	fi
done
log "ping fail and kill network_stress_test.sh"
killall network_stress_test.sh > /dev/null 2>&1
killall iperf3 > /dev/null 2>&1
