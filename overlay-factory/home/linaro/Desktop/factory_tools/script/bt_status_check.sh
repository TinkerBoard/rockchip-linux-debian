# /bin/bash

BT_STATUS=$(hciconfig hci0 | grep -i 'running' 2>&1 >/dev/null; echo $?)
if [ $BT_STATUS = "0" ]; then
	echo "PASS"
else
	echo "FAIL"
fi
