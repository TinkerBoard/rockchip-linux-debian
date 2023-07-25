#!/bin/sh

echo "thermal logging $1 $2 "
sudo killall tegrastats
sudo tegrastats > $2

