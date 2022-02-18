#!/bin/bash -e

# Directory contains the target rootfs
TARGET_ROOTFS_DIR="binary"

if [ -e $TARGET_ROOTFS_DIR ]; then
	sudo rm -rf $TARGET_ROOTFS_DIR
fi

case "${ARCH:-$1}" in
	arm|arm32|armhf)
		ARCH=armhf
		;;
	*)
		ARCH=arm64
		;;
esac

echo -e "\033[36m Building for $ARCH \033[0m"

if [ ! $VERSION ]; then
	VERSION="release"
fi

if [ ! -e linaro-buster-alip-*.tar.gz ]; then
	echo -e "\033[36m Run mk-base-debian.sh first \033[0m"
	exit -1
fi

finish() {
	sudo umount $TARGET_ROOTFS_DIR/dev
	exit -1
}
trap finish ERR

echo -e "\033[36m Extract image \033[0m"
sudo tar -xpf linaro-buster-alip-*.tar.gz

# packages folder
sudo mkdir -p $TARGET_ROOTFS_DIR/packages
sudo cp -rf packages/$ARCH/* $TARGET_ROOTFS_DIR/packages

# overlay folder
sudo cp -rf overlay/* $TARGET_ROOTFS_DIR/

# overlay-firmware folder
sudo cp -rf overlay-firmware/* $TARGET_ROOTFS_DIR/

# overlay-debug folder
# adb, video, camera  test file
if [ "$VERSION" == "debug" ]; then
	sudo cp -rf overlay-debug/* $TARGET_ROOTFS_DIR/
fi

# gpio library
sudo rm -rf $TARGET_ROOTFS_DIR/usr/local/share/gpio_lib_c_rk3399
sudo rm -rf $TARGET_ROOTFS_DIR/usr/local/share/gpio_lib_python_rk3399
sudo cp -rf overlay-debug/usr/local/share/gpio_lib_c_rk3399 $TARGET_ROOTFS_DIR/usr/local/share/gpio_lib_c_rk3399
sudo cp -rf overlay-debug/usr/local/share/gpio_lib_python_rk3399 $TARGET_ROOTFS_DIR/usr/local/share/gpio_lib_python_rk3399

# mraa library
sudo rm -rf $TARGET_ROOTFS_DIR/usr/local/share/mraa
sudo cp -rf overlay-debug/usr/local/share/mraa $TARGET_ROOTFS_DIR/usr/local/share/mraa

## hack the serial
sudo cp -f overlay/usr/lib/systemd/system/serial-getty@.service $TARGET_ROOTFS_DIR/lib/systemd/system/serial-getty@.service

# adb
if [ "$ARCH" == "armhf" ]; then
	sudo cp -f overlay-debug/usr/local/share/adb/adbd-32 $TARGET_ROOTFS_DIR/usr/bin/adbd
elif [ "$ARCH" == "arm64" ]; then
	sudo cp -f overlay-debug/usr/local/share/adb/adbd-64 $TARGET_ROOTFS_DIR/usr/bin/adbd
fi

# bt/wifi firmware
sudo mkdir -p $TARGET_ROOTFS_DIR/system/lib/modules/
sudo mkdir -p $TARGET_ROOTFS_DIR/vendor/etc
#sudo find ../kernel/drivers/net/wireless/rockchip_wlan/*  -name "*.ko" | \
#    xargs -n1 -i sudo cp {} $TARGET_ROOTFS_DIR/system/lib/modules/

# ASUS: Change to copy all the kernel modules built from build.sh.
sudo cp -rf lib_modules/lib/modules $TARGET_ROOTFS_DIR/lib/

echo -e "\033[36m Change root.....................\033[0m"
if [ "$ARCH" == "armhf" ]; then
	sudo cp /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin/
elif [ "$ARCH" == "arm64"  ]; then
	sudo cp /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin/
fi
sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR

apt-get update
apt-get upgrade -y

chmod o+x /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chmod +x /etc/rc.local

export APT_INSTALL="apt-get install -fy --allow-downgrades"

#---------------power management --------------
\${APT_INSTALL} busybox pm-utils triggerhappy
cp /etc/Powermanager/triggerhappy.service  /lib/systemd/system/triggerhappy.service

#---------------Rga--------------
\${APT_INSTALL} /packages/rga/*.deb

echo -e "\033[36m Setup Video.................... \033[0m"
\${APT_INSTALL} gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-alsa \
gstreamer1.0-plugins-base-apps qtmultimedia5-examples

\${APT_INSTALL} /packages/mpp/*
\${APT_INSTALL} /packages/gst-rkmpp/*.deb
\${APT_INSTALL} /packages/gst-base/*.deb

#---------Camera---------
echo -e "\033[36m Install camera.................... \033[0m"
\${APT_INSTALL} cheese v4l-utils
\${APT_INSTALL} /packages/rkisp/*.deb
\${APT_INSTALL} /packages/libv4l/*.deb
cp /packages/rkisp/librkisp.so /usr/lib/

#---------Xserver---------
echo -e "\033[36m Install Xserver.................... \033[0m"
\${APT_INSTALL} /packages/xserver/*.deb

#---------------Openbox--------------
echo -e "\033[36m Install openbox.................... \033[0m"
\${APT_INSTALL} /packages/openbox/*.deb

#---------update chromium-----
\${APT_INSTALL} /packages/chromium/*.deb

#------------------libdrm------------
echo -e "\033[36m Install libdrm.................... \033[0m"
\${APT_INSTALL} /packages/libdrm/*.deb

#------------------libdrm-cursor------------
echo -e "\033[36m Install libdrm-cursor.................... \033[0m"
\${APT_INSTALL} /packages/libdrm-cursor/*.deb

# Only preload libdrm-cursor for X
sed -i "/libdrm-cursor.so/d" /etc/ld.so.preload
sed -i "1aexport LD_PRELOAD=libdrm-cursor.so.1" /usr/bin/X

#------------------pcmanfm------------
echo -e "\033[36m Install pcmanfm.................... \033[0m"
\${APT_INSTALL} /packages/pcmanfm/*.deb

#------------------rkwifibt------------
echo -e "\033[36m Install rkwifibt.................... \033[0m"
\${APT_INSTALL} /packages/rkwifibt/*.deb
ln -s /system/etc/firmware /vendor/etc/

if [ "$VERSION" == "debug" ]; then
#------------------glmark2------------
echo -e "\033[36m Install glmark2.................... \033[0m"
\${APT_INSTALL} /packages/glmark2/*.deb
fi

# mark package to hold
apt list --installed | grep -v oldstable | cut -d/ -f1 | xargs apt-mark hold

#---------------Custom Script--------------
systemctl mask systemd-networkd-wait-online.service
systemctl mask NetworkManager-wait-online.service
rm /lib/systemd/system/wpa_supplicant@.service

#-------ASUS customization start-------
# Switching iptables/ip6tables to the legacy version
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

echo $VERSION_NUMBER-$VERSION > /etc/version

#-------- Florence Virtual Keyboard --------
apt-get install -y at-spi2-core
apt-get install -y florence

#---------------tinker-power-management--------------
cd /usr/local/share/tinker-power-management
gcc tinker-power-management.c -o tinker-power-management -lncursesw
mv tinker-power-management /usr/bin
cd /

# Change systemd-suspend.service method to pm-suspend
cp /etc/Powermanager/systemd-suspend.service  /lib/systemd/system/systemd-suspend.service

#---------------gpio library --------------
# For gpio wiring c library
chmod a+x /usr/local/share/gpio_lib_c_rk3399
cd /usr/local/share/gpio_lib_c_rk3399
./build
# For gpio python library
cd /usr/local/share/gpio_lib_python_rk3399/
python setup.py install
python3 setup.py install
cd /

#---------------mraa library --------------
apt-get install -y swig3.0
chmod a+x /usr/local/share/mraa
cd /usr/local/share/mraa
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr --BUILDARCH=aarch64 ..
make
make install
cd /

#---------------40 pin permission for user --------------
groupadd gpiouser
adduser linaro gpiouser
groupadd i2cuser
adduser linaro i2cuser
groupadd spidevuser
adduser linaro spidevuser
groupadd uartuser
adduser linaro uartuser
groupadd pwmuser
adduser linaro pwmuser

#----------------------------------------

# Test tool
if [ "$VERSION" == "debug" ]; then
	systemctl enable test.service
fi
update-alternatives --auto x-terminal-emulator

#-------ASUS customization end-------

#---------------Clean--------------
rm -rf /var/lib/apt/lists/*

EOF

sudo umount $TARGET_ROOTFS_DIR/dev
