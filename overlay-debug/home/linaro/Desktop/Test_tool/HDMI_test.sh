#!/bin/bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

echo "Start Display and play 1kHz sample test!"
echo "Enter Ctrl + Z to abort !"

/usr/bin/chromium  --start-fullscreen --no-sandbox $SCRIPTPATH/ScrollingH.html &
