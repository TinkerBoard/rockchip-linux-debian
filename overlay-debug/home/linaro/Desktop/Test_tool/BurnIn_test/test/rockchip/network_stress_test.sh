#!/bin/bash

logfile=$1
failcount1=0
passcount1=0
failcount2=0
passcount2=0
eth0_addr=192.168.100.100
eth1_addr=192.168.100.99
boardinfo=$(cat /proc/boardinfo)

log()
{
	start_time="$(date +'%Y/%m/%d/%H:%M:%S')"
	echo -e $start_time "network_stress " $1 | sudo tee -a $logfile
}

ip netns delete ns_server
ip netns delete ns_client
sleep 1

echo ""
oemid=$(cat /proc/odmid)
projectid=$(cat /proc/projectid)

if [ "$oemid" == "15" ]; then

	log "LAN Port Number : 1"
	log ""
elif [ "$oemid" == "18" ] && [ "$projectid" == "12" ]; then

	log "LAN Port Number : 1"
	log ""
else
	nslist=$(ip netns list)
	if [ "$nslist" == "" ]
	then
		eth0=$(ifconfig eth0 | grep "eth0")
		eth1=$(ifconfig eth1 | grep "eth1")
		if [ "$eth0" == "" ]
		then
			log "eth0 not exist" | tee -a $logfile
			exit
		elif [ "$eth1" == "" ]
		then
			log "eth1 not exist" | tee -a $logfile
			exit
		fi

		ip netns add ns_server
		ip netns add ns_client
		ip link set eth0 netns ns_server
		ip netns exec ns_server ip addr add dev eth0 $eth0_addr/24
		ip netns exec ns_server ip link set dev eth0 up
		ip link set eth1 netns ns_client
		ip netns exec ns_client ip addr add dev eth1 $eth1_addr/24
		ip netns exec ns_client ip link set dev eth1 up
		ip netns exec ns_server route add default gw 192.168.100.1
		ip netns exec ns_client route add default gw 192.168.100.1
		sleep 6
	fi

	while [ 1 != 2 ]
	do
		log
		log "============================================================"
		log "		Ethernet : LAN0-TX, LAN1-RX "
		log "============================================================"
		ip netns exec ns_client iperf3 -B "$eth1_addr" -s -i 10 --one-off &
		sleep 2
		ret=$(ip netns exec ns_server iperf3 -B "$eth0_addr" -c "$eth1_addr" -i 10 -t 10 --connect-timeout 3000 | tee -a $logfile | grep Done)
		if [ "$ret" == "" ]
		then
			((failcount1+=1))
		else
			((passcount1+=1))
			failconut1=0
		fi
		log "============================================================"
		log "failcount1=$failcount1, failcount2=$failcount2, passcount1=$passcount1, passcount2=$passcount2"
		log
		log
		log "============================================================"
		log "		Ethernet : LAN0-RX, LAN1-TX "
		log "=========================================================== "
		ip netns exec ns_client iperf3 -B "$eth1_addr" -s -i 10 --one-off &
		sleep 2
		ret=$(ip netns exec ns_server iperf3 -B "$eth0_addr" -c "$eth1_addr" -i 10 -t 10 --connect-timeout 3000 -R | tee -a $logfile | grep Done)
		if [ "$ret" == "" ]
		then
			((failcount2+=1))
		else
			((passcount2+=1))
			failcount2=0
		fi
		log "============================================================"
		log "failcount1=$failcount1, failcount2=$failcount2, passcount1=$passcount1, passcount2=$passcount2"
		log
		log
		sleep 3

		if [ "$failcount1" -ge 6  ] || [ "$failcount2" -ge 6  ]
		then
			log "network tansmissoin fail over 6 times."
			log "LAN0 TX : pass time = $passcount1 fail time $failcount1 "
			log "LAN0 RX : pass time = $passcount2 fail time $failcount2 "
			exit
		fi
	done
fi
