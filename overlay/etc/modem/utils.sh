#!/usr/bin/bash
AT_CMD_TEMP=/etc/modem/at_cmd_tmp
TIMEOUT=2000
AT_PORT=/dev/ttyUSB2

send_at_command() {
	if [ -z "$1" ]
	then
		echo "ERROR no command"
		return 1
	fi

	# For sending command via mmcli, it needs to remove the "AT" header
	if [[ "${1^^}" == "AT"* ]]
	then
		CMD=$(echo ${1^^}| sed 's/AT//')
	else
		CMD=$1
	fi

	# Send command and save result into $AT_CMD_TEMP
	RET=$(mmcli -m any -a --command="$CMD" \
	       	| tr '\r' ' '\
		| tr -d '\n')
	echo "$RET" >> $AT_CMD_TEMP
	chmod a+w $AT_CMD_TEMP

	if [[ "$RET" =~ "error" ]]
	then
		echo "ERROR command failed"
		return 1
	elif [ "$RET" == "" ]
	then
		send_at_command_directly $1
	else
		echo $RET| sed -rn "s/^response: +'([^']+)'.*/\1/p"
		return 0
	fi
}

send_at_command_directly() {
	if [ -e $AT_PORT ]; then
		# Send AT command via $AT_PORT
		RET=$(echo -ne "${1^^}\r"\
			| busybox microcom -t ${TIMEOUT} ${AT_PORT}\
			| tr '\r' ' '\
			| tr -d '\n')
		echo "$RET"
		return 0
	else
		echo "ERROR $AT_PORT not found"
		return 1
	fi	
}

wait_until_modem_available() {
	while ! mmcli -L
	do
		sleep 1
	done
	sleep 3
}

clear_modem_logs() {
	echo "" > $AT_CMD_TEMP
}
