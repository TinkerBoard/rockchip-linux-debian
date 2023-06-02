#!/bin/bash
MODEM_FOLDER=/etc/modem
UTILS=$MODEM_FOLDER/utils.sh
ACK=$MODEM_FOLDER/lte_ack
QMI=/dev/cdc-wdm0

read_result() {
    result=`cat ${ACK} | tr -d '\r'`
    if [[ ${result^^} == *"ERROR"* ]]; then
        result="FAIL"
    elif [ "$1" == "rssi" ]; then
        result=`echo ${result##*,}`
        result=`echo ${result%%\ *}`
        if [ "$result" == "" ] || [ $result -gt 0 ]; then
            result="FAIL"
        fi
    elif [ "$1" == "qmi" ]; then
        result=`echo ${result##*: \'}`
        result=`echo ${result%%\'}`
    else
        result=`echo ${result##*${1}}`
        result=`echo ${result%OK*}`
        if [ "$result" == "" ]; then
            result="FAIL"
        fi
    fi
}

show_usage() {
    echo "Usage: ./lte_test.sh rssi     [Band] [Channel] [0/1]"
    echo "                     rssi_5g  [Band] [Channel]"
    echo "                     get_info"
    echo "                     test_qmi"
    exit 1
}

source $UTILS
case $1 in
get_info)
    send_at_command_directly "AT+CGSN" > $ACK
    read_result "AT+CGSN"
    imei=$result

    send_at_command_directly "AT+CIMI" > $ACK
    read_result "AT+CIMI"
    imsi=$result

    send_at_command_directly "AT+QGMR" > $ACK
    read_result "AT+QGMR"
    ver=$result

    result=${imei},${imsi},${ver}
    ;;
test_qmi)
    qmicli -d "$QMI" -p --dms-get-model &> $ACK
    read_result "qmi"
    ;;
rssi)
    if [ "$2" != "" ] && [ "$3" != "" ] && [ "$4" != "" ]; then
        send_at_command_directly "AT+QRFTESTMODE=1" > /dev/null
        send_at_command_directly "AT+QRXFTM=1,${2},${3},${4},0,3" > $ACK
        read_result "rssi"
        send_at_command_directly "AT+QRFTESTMODE=0" > /dev/null
    else
        show_usage
    fi
    ;;
rssi_5g)
    if [ "$2" != "" ] && [ "$3" != "" ]; then
        send_at_command_directly "AT+QFTMMODE=1" > /dev/null

        send_at_command_directly "AT+QRFTESTEX=\"LTE\",\"rx\",${2},0,-600,1,${3}" > $ACK
        read_result "+QRFTESTEX:"
        sig0=$result
        send_at_command_directly "AT+QRFTESTEX=\"LTE\",\"rx\",${2},0,-600,0,${3}" > /dev/null

        send_at_command_directly "AT+QRFTESTEX=\"LTE\",\"rx\",${2},1,-600,1,${3}" > $ACK
        read_result "+QRFTESTEX:"
        sig1=$result
        send_at_command_directly "AT+QRFTESTEX=\"LTE\",\"rx\",${2},1,-600,0,${3}" > /dev/null

        send_at_command_directly "AT+QRFTESTEX=\"LTE\",\"rx\",${2},2,-600,1,${3}" > $ACK
        read_result "+QRFTESTEX:"
        sig2=$result
        send_at_command_directly "AT+QRFTESTEX=\"LTE\",\"rx\",${2},2,-600,0,${3}" > /dev/null

        send_at_command_directly "AT+QRFTESTEX=\"LTE\",\"rx\",${2},3,-600,1,${3}" > $ACK
        read_result "+QRFTESTEX:"
        sig3=$result
        send_at_command_directly "AT+QRFTESTEX=\"LTE\",\"rx\",${2},3,-600,0,${3}" > /dev/null

        send_at_command_directly "AT+QFTMMODE=0" > /dev/null
        result=${sig0},${sig1},${sig2},${sig3}
    else
        show_usage
    fi
    ;;
*)
    show_usage
    ;;
esac
echo $result
