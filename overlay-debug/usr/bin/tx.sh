#!/bin/bash

function logi {
  logger -t "WifiTestCmd-tx" $1
}

iface=wlp1s0
mode=$1
channel=$2
powera=$3
powerb=$4
ant=$5
bw=$6
txmode=$8


case $bw in
40)  bw=1;;
80)  bw=2;;
*)   bw=0;;
esac

case $mode in
0)
  logi "rtwpriv $iface stop"
  rtwpriv $iface stop
  exit
  ;;
a|b|g)
  rate=$7"M"
  ;;
n)
  rate="HT"$7
  ;;
ac)
  if [ $ant -eq 2 ]; then
    rate="VHT2"$7
  else
    rate="VHT1"$7
  fi
  ;;
esac

if [ $ant -eq 0 ]; then
  ant=a
elif [ $ant -eq 1 ]; then
  ant=b
else
  ant=ab
fi

logi "rtwpriv $iface stop"
rtwpriv $iface stop

logi "rtwpriv $iface mp_txpower patha=$powera,pathb=$powerb"
rtwpriv $iface mp_txpower patha=$powera,pathb=$powerb

logi "rtwpriv $iface $channel $bw $ant $rate $txmode"
rtwpriv $iface $channel $bw $ant $rate $txmode

logi "rtwpriv $iface mp_txpower patha=$powera,pathb=$powerb"
rtwpriv $iface mp_txpower patha=$powera,pathb=$powerb