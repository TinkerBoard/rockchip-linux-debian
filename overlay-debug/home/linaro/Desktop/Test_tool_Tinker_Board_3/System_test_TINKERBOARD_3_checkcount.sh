#!/bin/bash

version=2.9.20230918

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`/System_test

sudo $SCRIPTPATH/System_test.sh TINKERBOARD_3 5

read -n 1 -p "$*" INP

