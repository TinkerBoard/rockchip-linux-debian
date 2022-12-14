#!/bin/bash
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

$SCRIPTPATH/rknn_common_test $SCRIPTPATH/mobilenet_v1.rknn $SCRIPTPATH/dog_224x224.jpg 30;
