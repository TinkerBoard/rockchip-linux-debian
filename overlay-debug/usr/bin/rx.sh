#!/bin/bash

function logi {
  logger -t "WifiTestCmd-rx" $1
}

iface=wlp1s0
mode=$1
channel=$2
ant=$3
bw=$4

case $bw in
40) bw=1;;
80) bw=2;;
*)  bw=0;;
esac

logi "rtwpriv $iface mp_bandwidth 40M=$bw,shortGI=0"
rtwpriv $iface mp_bandwidth 40M=$bw,shortGI=0

logi "rtwpriv $iface mp_channel $channel"
rtwpriv $iface mp_channel $channel

if [ $ant -eq 0 ]; then
  ant=a
elif [ $ant -eq 1 ]; then
  ant=b
else
  ant=ab
fi
logi "rtwpriv $iface mp_ant_rx $ant"
rtwpriv $iface mp_ant_rx $ant

logi "rtwpriv $iface mp_arx start"
rtwpriv $iface mp_arx start
