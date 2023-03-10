#!/bin/bash

function usage {
  echo "WifiTest Usage Instruction"
  echo "============================================================================"
  echo "Command ID1: Enter/Exit Wifi MFG Test Mode"
  echo "Para1 = 1, Para2 = 0/1(off/on), Para3 = timeout"
  echo ""
  echo "Command ID 9: ATD Rx Command"
  echo "Start Rx:"
  echo "Para1 = 9, Para2 = mode(a/b/g/n/ac), Para3 = channel"
  echo "Para4 = ant:0(main)/1(aux)/2(both)"
  echo "Para5 = BW(20/40/80), Para6 = rate(11/54/MCS7)"
  echo "Get Rx result: Para1 = 9, Para2= 1"
  echo "Stop Rx: Para1 = 9, Para2 = 0"
  echo ""
  echo "Command ID 10: Tx Related Command"
  echo "Start Tx:"
  echo "Para1 = 10, Para2 = mode(a/b/g/n/ac), Para3 = channel"
  echo "Para4 = main ant power(0~63), Para5 = aux ant power (0~63)"
  echo "Para6 = ant:0(main)/1(aux)/2(both)"
  echo "Para7 = BW(20/40/80)"
  echo "Para8 = rate(11/54/MCS7)"
  echo "Para9 = tx mode(1: packet tx, 2: continuous tx, 3:single tone)"
  echo "Stop Tx: Para1 = 10, Para2 = 0"
  echo "============================================================================"
}

function logi {
  logger -t "WifiTestCmd" $@
}

found="False"
iface=wlp1s0

logi "WifiTest $@"
case $1 in
1)
  case $2 in
  1)
    begin=$(date +%s)
    while true
    do
      logi "stop wpa_supplicant.service"
      systemctl stop wpa_supplicant.service
      logi "rtwpriv $iface mp_start"
      result=$(rtwpriv $iface mp_start)
      echo $result
      if [[ $result == *ok* ]]; then
        echo "PASS"
        exit
      fi
      now=$(date +%s)
      diff=$(($now - $begin))
      if [ $diff -lt $3 ]; then
        sleep 1
      else
        echo "FAIL"
        exit
      fi
    done
    ;;
  0)
    begin=$(date +%s)
    while true
    do
      rtwpriv $iface mp_tx stop
      rtwpriv $iface mp_arx stop
      logi "rtwpriv $iface mp_stop"
      result=$(rtwpriv $iface mp_stop)
      echo $result
      if [[ $result == *ok* ]]; then
        systemctl start wpa_supplicant.service
        echo "PASS"
        exit
      fi
      now=$(date +%s)
      diff=$(($now - $begin))
      if [ $diff -lt $3 ]; then
        sleep 1
      else
        echo "FAIL"
        exit
      fi
    done
    ;;
  *)
    echo "Invalid Para2"
    ;;
  esac
  ;;
9)
  case $2 in
  0)
    WifiTest.sh 9 1
    logi "rtwpriv $iface mp_reset_stats"
    rtwpriv $iface mp_reset_stats > /dev/null 2>&1
    logi "rtwpriv $iface mp_arx stop"
    rtwpriv $iface mp_arx stop > /dev/null 2>&1
    ;;
  1)
    logi "rtwpriv $iface mp_arx phy"
    result=$(rtwpriv $iface mp_arx phy)
    for var in $result
    do
      if [[ $var == *OK:* ]]; then
        pkt=${var:3:20}
        echo "Number of received packets=$pkt"
        break
      fi
    done
    ;;
  a|b|g|n|ac)
#    rx.sh $2 $3 $4 $5 > /dev/null 2>&1
    rx.sh $2 $3 $4 $5
    WifiTest.sh 9 1
    ;;
  *)
    echo "Invalid Para2"
    ;;
  esac
  ;;
10)
  case $2 in
  0|a|b|g|n|ac)
#   tx.sh $2 $3 $4 $5 $6 $7 > /dev/null 2>&1
    tx.sh $2 $3 $4 $5 $6 $7 $8 $9
    ;;
  *)
    echo "Invalid Para2"
    ;;
  esac
  echo "PASS"
  ;;
12)
  echo "RTL8822CE"
  ;;
h)
  usage
  ;;
*)
  echo "Unsupport Command ID"
  ;;
esac
