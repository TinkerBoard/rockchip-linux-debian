#!/bin/bash
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

$SCRIPTPATH/rknn_common_test $SCRIPTPATH/mobilenet_v1.rknn $SCRIPTPATH/dog_224x224.jpg | grep -wq "0.984375 - 156"
if [ $? -eq 0 ]
then
	echo "PASS"
else
	echo "FAIL"
fi
