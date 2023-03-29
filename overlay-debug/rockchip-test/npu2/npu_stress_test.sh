#!/bin/bash

COMPATIBLE=$(cat /proc/device-tree/compatible)


while true
do
if [[ $COMPATIBLE =~ "rk3588" ]]; then
    rknn_common_test /usr/share/model/RK3588/mobilenet_v1.rknn /usr/share/model/dog_224x224.jpg 10
elif [[ $COMPATIBLE =~ "rk3562" ]]; then
    ln -sf /usr/share/model/RK3562/mobilenet_v2 /data/mobilenet_v2
    ln -sf /usr/share/model/RK3562/resnet_50 /data/resnet_50
    ln -sf /usr/share/model/RK3562/vgg16_max_pool /data/vgg16_max_pool
    rknn_stress_test /usr/share/model/RK3562/mobilenet_v2/mobilenet_v2_fp16.cfg 10
    rknn_stress_test /usr/share/model/RK3562/resnet_50/resnet_50_fp16.cfg 10
    rknn_stress_test /usr/share/model/RK3562/vgg16_max_pool/vgg16_max_pool_fp16.cfg 10
else
    rknn_common_test /usr/share/model/RK356X/mobilenet_v1.rknn /usr/share/model/dog_224x224.jpg 10
fi
done
