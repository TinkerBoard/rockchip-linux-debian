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
        if [ $result -gt 0 ]; then
            result="FAIL"
        fi
    elif [ "$1" == "qmi" ]; then
        result=`echo ${result##*: \'}`
        result=`echo ${result%%\'}`
    else
        result=`echo ${result##*${1}}`
        result=`echo ${result%OK*}`
    fi
}

show_usage() {
    echo "Usage: $0 {get_info | test_qmi}"
    exit 1
}

source $UTILS
case $1 in
get_info)
    send_at_command "AT+CGSN" > $ACK
    read_result "AT+CGSN"
    imei=$result

    send_at_command "AT+CIMI" > $ACK
    read_result "AT+CIMI"
    imsi=$result

    send_at_command "AT+QGMR" > $ACK
    read_result "AT+QGMR"
    ver=$result

    result=${imei},${imsi},${ver}
    ;;
test_qmi)
    qmicli -d "$QMI" -p --dms-get-model &> $ACK
    read_result "qmi"
    ;;
*)
    show_usage
    ;;
esac
echo $result
