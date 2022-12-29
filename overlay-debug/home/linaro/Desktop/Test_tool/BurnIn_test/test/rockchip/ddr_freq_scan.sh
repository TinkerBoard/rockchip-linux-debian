#!/bin/bash

DMC_PATH1=/sys/class/devfreq/dmc
DMC_PATH2=/sys/bus/platform/drivers/rockchip-dmc/dmc/devfreq/dmc

if [ -d "$DMC_PATH1" ];then
    DMC_PATH=$DMC_PATH1
elif [ -d $DMC_PATH2 ];then
    DMC_PATH=$DMC_PATH2
else
    echo "non-existent dmc path,please check if enable dmc"
    exit
fi

echo "DMC_PATH:"$DMC_PATH

if [ "$#" -eq "1" ];then
    echo userspace > $DMC_PATH/governor
    echo $1 > $DMC_PATH/userspace/set_freq
    val=$(cat $DMC_PATH/cur_freq)
    echo "already change to" $val"Hz done."
    array=($(cat $DMC_PATH/available_frequencies))
    let j=${#array[@]}-1
    if [ "$val" -eq "${array[j]}" ];then
        echo "change frequency to available max frequency done."
    else
        echo "!!!warning!!!"
        echo "!!!warning!!! available max frequency is" ${array[j]}"Hz"
        echo "!!!warning!!! please check frequency" $val"Hz if you need."
        echo "!!!warning!!!"
    fi
    exit
else
    array=($(cat $DMC_PATH/available_frequencies))

    echo "available_frequencies:"
    let j=${#array[@]}-1
    for i in `seq 0 $j`
    do
        echo ${array[i]}
    done

    i=0
    while true;
    do
        val=$(cat /proc/sys/kernel/random/uuid| cksum | cut -f1 -d" ")
        let val=$(($val%${#array[@]}))
        let val=$(($val+${#array[@]}))
        let val=$(($val%${#array[@]}))

        echo userspace > $DMC_PATH/governor
        echo ${array[0]} > $DMC_PATH/min_freq

        echo "DDR freq will change to" ${array[val]} $i
        echo ${array[val]} > $DMC_PATH/userspace/set_freq
        val=$(cat $DMC_PATH/cur_freq)
        echo "already change to" $val "done"

        let i=$(($i+1))
    done
fi
