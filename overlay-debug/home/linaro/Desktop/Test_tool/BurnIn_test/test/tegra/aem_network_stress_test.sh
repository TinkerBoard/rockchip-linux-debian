#!/bin/bash
# For PE1000N
# eqos: NX/TX2 SOM LAN (near power)
# r8168: NANO SOM LAN
# r8152: on board USB LAN
# igb: AEM-LAN

logfile=$1
flag=0
failcount1=0
passcount1=0
failcount2=0
passcount2=0
eth2_addr=192.168.200.100
eth3_addr=192.168.200.99
nslist=$(ip netns list)
retry=0
log()
{
	start_time="$(date +'%Y/%m/%d/%H:%M:%S')"
	echo -e $start_time "aem_network_stress " $1 | sudo tee -a $logfile
}

#ip -all netns delete
#sleep 4

#eth2=$(ifconfig eth2 | grep "eth2")
#eth3=$(ifconfig eth3 | grep "eth3")
#if [ "$eth2" == "" ]
#then
#	echo "eth2 not exist" | tee -a $logfile
#	exit
#elif [ "$eth3" == "" ]
#then
#	echo "eth3 not exist" | tee -a $logfile
#	exit
#fi
ip netns delete aem_server
ip netns delete aem_client
sleep 1
ip netns add aem_server
ip netns add aem_client
ip link set eth2 netns aem_server
ip netns exec aem_server ip addr add dev eth2 $eth2_addr/24
ip netns exec aem_server ip link set dev eth2 up
ip link set eth3 netns aem_client
ip netns exec aem_client ip addr add dev eth3 $eth3_addr/24
ip netns exec aem_client ip link set dev eth3 up
ip netns exec aem_server route add default gw 192.168.200.1
ip netns exec aem_client route add default gw 192.168.200.1
sleep 6

while [ 1 != 2 ]
do
		#if dmesg -T | grep "usb 2-2.4: USB disconnect" > /dev/null
		#if dmesg -T | grep "xhci: HC died" > /dev/null
		#then
		#	log "detect usb contoller hang stop test and wait burin.sh launch again"
		#fi 
		ipresults=`ip netns | grep aem_server`
		if [ -z "$ipresults" ] ; then	
			ip netns add aem_server
			ip netns add aem_client
			ip link set eth2 netns aem_server
			ip netns exec aem_server ip addr add dev eth2 $eth2_addr/24
			ip netns exec aem_server ip link set dev eth2 up
			ip link set eth3 netns aem_client
			ip netns exec aem_client ip addr add dev eth3 $eth3_addr/24
			ip netns exec aem_client ip link set dev eth3 up
	
			ip netns exec aem_server route add default gw 192.168.200.1
			ip netns exec aem_client route add default gw 192.168.200.1
			log "ip was empty, set again"
			sleep 6
		fi 
		echo
		echo
		echo "============================================================"
		echo "		LAN3 Tx -> LAN4 Rx Start "
		echo "          $logfile"
		ip netns exec aem_client iperf3 --one-off -s -B "$eth3_addr" -i 10 &
		sleep 2
		ret=$(ip netns exec aem_server iperf3 -c "$eth3_addr" -B "$eth2_addr" -i 10 -t 30 --connect-timeout 3000 --rcv-timeout 3000 | tee -a $logfile | grep Done)
		if [ "$ret" == "" ]
		then
			((failcount1+=1))
		else
			((passcount1+=1))
			failcount1=0
			retry=0
		fi
		flag=1
		echo "============================================================"
		log "failcount1=$failcount1, failcount2=$failcount2, passcount1=$passcount1, passcount2=$passcount2"
		echo
		echo
		#sleep 3
	
		echo
		echo
		echo "============================================================"
		echo "		LAN4 Tx -> LAN3 Rx Start "
		echo "          $logfile"
		ip netns exec aem_client iperf3 --one-off -s -B "$eth3_addr" -i 10 &
		sleep 2
		ret=$(ip netns exec aem_server iperf3 -c "$eth3_addr" -B "$eth2_addr" -i 10 -t 30 -R --connect-timeout 3000 --rcv-timeout 3000 | tee -a $logfile | grep Done)
		if [ "$ret" == "" ]
		then
			((failcount2+=1))
		else
			((passcount2+=1))
			failcount2=0
			retry=0
		fi
		flag=0
		echo "============================================================"
		log "failcount1=$failcount1, failcount2=$failcount2, passcount1=$passcount1, passcount2=$passcount2"
		echo
		echo
		sleep 3
	
		# Retry when burnin.sh detect usb controller hang 
		#if [ "$failcount1" -ge 2  ] || [ "$failcount2" -ge 2  ] && [ "$retry" -ne 4 ]
		#then
		#	log "delet ip and retry [$retry]"
		#	ip netns delete aem_server
		#	ip netns delete aem_client
		#	failcount1=0
		#	failcount2=0
		#	((retry+=1))
		#	sleep 10
		#fi
	
		if [ "$failcount1" -ge 5  ] || [ "$failcount2" -ge 5  ]
		then
			log "network tansmissoin fail over 5 times."
			log "LAN3 TX pass time = $passcount1 fail time $failcount1 "
			log "LAN4 TX pass time = $passcount2 fail time $failcount2 "
			exit
		fi
done
