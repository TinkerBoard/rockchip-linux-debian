#!/bin/bash

thermal=$(cat /sys/class/thermal/thermal_zone0/temp)

echo "$thermal"
