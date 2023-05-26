#!/bin/bash -e

#pin_name=(252 253 17 164 166 167 257 256 254 233 165 168 238 185 224 161 160 184 162 163 171 255 251 234 239 223 187 188)

Reg="$1"

#for ((i=0 ; i<${#pin_name[*]} ; i++)) do
#    echo "${pin_name[i]}"
#    echo ${pin_name[i]} > /sys/class/gpio/export
#done

echo ${Reg} > /sys/class/gpio/export


