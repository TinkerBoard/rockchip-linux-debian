#!/bin/bash

sleep 5
err_cnt=0
logfile=$1

log()
{
	start_time="$(date +'%Y/%m/%d/%H:%M:%S')"
	echo -e $start_time "check_aem_network " $1 | sudo tee -a $logfile
}

while [ 1 != 2 ]
do
	if dmesg -T | grep "xhci: HC died" > /dev/null
	then
		log "detect USB contoller hang"
		err_cnt=0
		sleep 60
		#dmesg -C
	else
		ipresults=`ip netns | grep aem_server`
		if [ ! -z "$ipresults" ] ; then
			#if ip netns exec ns_server ping -c 1 192.168.100.99 &> /dev/null
			#then
			#	err_cnt=0
			#	log "ping -c 1 192.168.100.99 pass [$err_cnt]"
			#else
			#	((err_cnt+=1))
			#	log "ping -c 1 192.168.100.99 fail [$err_cnt]"
			#fi
			#if ip netns exec ns_client ping -c 1 192.168.100.100 &> /dev/null
			#then
			#	err_cnt2=0
			#	echo "ping -c 1 192.168.100.100 pass [$err_cnt2]"
			#else
			#	((err_cnt2+=1))
			#	echo "ping -c 1 192.168.100.100 fail [$err_cnt2]" | tee -a $logfile
			#fi
			if ip netns exec aem_server ping -c 1 192.168.200.99 &> /dev/null
			then
				err_cnt=0
				log "ping -c 1 192.168.200.99 pass "
			else
				((err_cnt+=1))
				log "ping -c 1 192.168.200.99 fail [$err_cnt]"
			fi
			#if ip netns exec ns_client2 ping -c 1 192.168.200.100 &> /dev/null
			#then
			#	err_cnt4=0
			#	echo "ping -c 1 192.168.200.100 pass [$err_cnt4]"
			#else
			#	((err_cnt4+=1))
			#	echo "ping -c 1 192.168.200.100 fail [$err_cnt4]" | tee -a $logfile
			#fi
	
			if [ $err_cnt -gt 60 ]; then
				break
			fi
		else
	       	log "ip was delete"
			err_cnt=0
			sleep 60
		fi
	fi
done
log "ping fail [$err_cnt] and kill aem_network_stress_test.sh"
killall aem_network_stress_test.sh > /dev/null 2>&1
killall iperf3 > /dev/null 2>&1
