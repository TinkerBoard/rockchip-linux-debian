#!/bin/bash

date_input=$1

date -s $date_input
sudo hwclock -w
sudo hwclock -r
