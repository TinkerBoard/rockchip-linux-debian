#!/bin/bash

function pause(){
	read -n 1 -p "$*" INP
	echo -ne '\b \n'
}

sudo apt-get update
sudo apt-get install -y python3 python3-dev python3-pip gcc g++
pip3 install pip --upgrade
pip3 install --user /usr/local/share/debian11_rknn_toolkit_lite2/rknn_toolkit_lite2-1.5.0-cp39-cp39-linux_aarch64.whl
pip3 install --user opencv-python opencv-contrib-python
sudo apt-get autoremove -y

pause 'Press any key to continue...'
