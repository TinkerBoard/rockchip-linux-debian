#!/bin/sh
sleep 1

nmcli con del "Wired connection 1"
nmcli con del "eth0"
nmcli con add con-name eth0 ifname eth0 type Ethernet ipv4.addresses 192.168.100.100/24 ipv4.method manual
nmcli con down eth0
nmcli con up eth0

exit 0