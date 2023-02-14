#!/bin/bash

version=1.0

info_view()
{
	echo "************************************************"
	echo
	echo                "Storage Benchmark Test v_$version"
	echo
	echo "************************************************"
	echo
	read -p "Enter test path: " test_path
	echo
}
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
info_view

echo "Start Write Test"
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
sudo dd if=/dev/zero of=$test_path/tmpfile bs=256M count=15 conv=fdatasync

echo "Start Read Test"
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
sudo dd if=$test_path/tmpfile of=/dev/null bs=256M count=15
sudo rm $test_path/tmpfile

