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
	VERSION="debug"
fi

# Initialized to "eng", however this should be set in build.sh
if [ ! $VERSION_NUMBER ]; then
        VERSION_NUMBER="eng"
fi

if [ ! -e linaro-bullseye-alip-*.tar.gz ]; then
	echo "\033[36m Run mk-base-debian.sh first \033[0m"
	exit -1
fi

finish() {
	sudo umount $TARGET_ROOTFS_DIR/dev
	exit -1
}
trap finish ERR

echo -e "\033[36m Extract image \033[0m"
sudo tar -xpf linaro-bullseye-alip-*.tar.gz

# packages folder
sudo mkdir -p $TARGET_ROOTFS_DIR/packages
sudo cp -rf packages/$ARCH/* $TARGET_ROOTFS_DIR/packages

# overlay folder
sudo cp -rf overlay/* $TARGET_ROOTFS_DIR/

# overlay-firmware folder
sudo cp -rf overlay-firmware/* $TARGET_ROOTFS_DIR/
sudo mkdir -p $TARGET_ROOTFS_DIR/tmp_firmware
sudo cp -rf overlay-firmware/usr/lib/firmware/* $TARGET_ROOTFS_DIR/tmp_firmware

# overlay-debug folder
# adb, video, camera  test file
if [ "$VERSION" == "debug" ]; then
	sudo cp -rf overlay-debug/* $TARGET_ROOTFS_DIR/
        sudo rm -rf $TARGET_ROOTFS_DIR/home/linaro/Desktop/Test_tool
        sudo cp -arp overlay-debug/home/linaro/Desktop/Test_tool $TARGET_ROOTFS_DIR/home/linaro/Desktop/
fi
## hack the serial
sudo cp -f overlay/usr/lib/systemd/system/serial-getty@.service $TARGET_ROOTFS_DIR/usr/lib/systemd/system/serial-getty@.service

# adb
if [[ "$ARCH" == "armhf" && "$VERSION" == "debug" ]]; then
	sudo cp -f overlay-debug/usr/local/share/adb/adbd-32 $TARGET_ROOTFS_DIR/usr/bin/adbd
elif [[ "$ARCH" == "arm64" && "$VERSION" == "debug" ]]; then
	sudo cp -f overlay-debug/usr/local/share/adb/adbd-64 $TARGET_ROOTFS_DIR/usr/bin/adbd
fi

# bt/wifi firmware
sudo mkdir -p $TARGET_ROOTFS_DIR/system/lib/modules/
sudo mkdir -p $TARGET_ROOTFS_DIR/vendor/etc

sudo find ../kernel/drivers/net/wireless/rockchip_wlan/*  -name "*.ko" | \
    xargs -n1 -i sudo cp {} $TARGET_ROOTFS_DIR/system/lib/modules/

echo -e "\033[36m Change root.....................\033[0m"
if [ "$ARCH" == "armhf" ]; then
	sudo cp /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin/
elif [ "$ARCH" == "arm64"  ]; then
	sudo cp /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin/
fi

sudo cp -f /etc/resolv.conf $TARGET_ROOTFS_DIR/etc/

#sudo find ../kernel/drivers/net/wireless/rockchip_wlan/*  -name "*.ko" | \
#    xargs -n1 -i sudo cp {} $TARGET_ROOTFS_DIR/system/lib/modules/

# ASUS: Change to copy all the kernel modules built from build.sh.
sudo cp -rf lib_modules/lib/modules $TARGET_ROOTFS_DIR/lib/


sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR

apt-get update
apt-get upgrade -y

chmod o+x /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chmod +x /etc/rc.local

export APT_INSTALL="apt-get install -fy --allow-downgrades"

#---------------power management --------------
\${APT_INSTALL} pm-utils triggerhappy bsdmainutils
cp /etc/Powermanager/triggerhappy.service  /lib/systemd/system/triggerhappy.service

#---------------Rga--------------
\${APT_INSTALL} /packages/rga2/*.deb

echo -e "\033[36m Setup Video.................... \033[0m"
\${APT_INSTALL} gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-ugly gstreamer1.0-tools gstreamer1.0-alsa \
gstreamer1.0-plugins-base-apps qtmultimedia5-examples

\${APT_INSTALL} /packages/mpp/*
\${APT_INSTALL} /packages/gst-rkmpp/*.deb
\${APT_INSTALL} /packages/gstreamer/*.deb
\${APT_INSTALL} /packages/gst-plugins-base1.0/*.deb
\${APT_INSTALL} /packages/gst-plugins-bad1.0/*.deb
\${APT_INSTALL} /packages/gst-plugins-good1.0/*.deb
\${APT_INSTALL} /packages/gst-plugins-ugly1.0/*.deb
\${APT_INSTALL} /packages/gst-libav1.0/*.deb

#---------Camera---------
echo -e "\033[36m Install camera.................... \033[0m"
\${APT_INSTALL} cheese v4l-utils
\${APT_INSTALL} /packages/libv4l/*.deb

#---------Network----------
apt-get install -y ethtool
apt-get install -y iperf3

#---------Xserver---------
echo -e "\033[36m Install Xserver.................... \033[0m"
\${APT_INSTALL} /packages/xserver/*.deb

apt-mark hold xserver-common xserver-xorg-core xserver-xorg-legacy

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

#------------------blueman------------
echo -e "\033[36m Install blueman.................... \033[0m"
\${APT_INSTALL} blueman
echo exit 101 > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
\${APT_INSTALL} blueman
rm -f /usr/sbin/policy-rc.d

# Change the background for ASUS Tinker Board
rm -rf /usr/share/images/desktop-base/default
ln -s /etc/ASUS/ASUS-2017-Tinkerboard-v1-wp-02-1920x1080.jpg /usr/share/images/desktop-base/default

#------------------rkwifibt------------
echo -e "\033[36m Install rkwifibt.................... \033[0m"
\${APT_INSTALL} /packages/rkwifibt/*.deb
ln -s /system/etc/firmware /vendor/etc/

#------------------modemmanager--------
echo -e "\033[36m Install modemmanager................ \033[0m"
\${APT_INSTALL} /packages/modemmanager/*.deb

if [ "$VERSION" == "debug" ]; then
#------------------glmark2------------
echo -e "\033[36m Install glmark2.................... \033[0m"
\${APT_INSTALL} /packages/glmark2/*.deb
fi

if [ -e "/usr/lib/aarch64-linux-gnu" ] ;
then
#------------------rknpu2------------
echo -e "\033[36m move rknpu2.................... \033[0m"
mv /packages/rknpu2/*.tar  /
fi

#------------------rktoolkit------------
echo -e "\033[36m Install rktoolkit.................... \033[0m"
\${APT_INSTALL} /packages/rktoolkit/*.deb

echo -e "\033[36m Install Chinese fonts.................... \033[0m"
# Uncomment zh_CN.UTF-8 for inclusion in generation
# sed -i 's/^# *\(zh_CN.UTF-8\)/\1/' /etc/locale.gen
# echo "LANG=zh_CN.UTF-8" >> /etc/default/locale

# Generate locale
# locale-gen

# Export env vars
# echo "export LC_ALL=zh_CN.UTF-8" >> ~/.bashrc
# echo "export LANG=zh_CN.UTF-8" >> ~/.bashrc
# echo "export LANGUAGE=zh_CN.UTF-8" >> ~/.bashrc

source ~/.bashrc

\${APT_INSTALL} ttf-wqy-zenhei fonts-aenigma
\${APT_INSTALL} xfonts-intl-chinese

# HACK debian11.3 to fix bug
\${APT_INSTALL} fontconfig --reinstall

#\${APT_INSTALL} xfce4
#ln -sf /usr/bin/startxfce4 /etc/alternatives/x-session-manager

#---------------Install thunar-volman and auto mount storage start--------------
\${APT_INSTALL} thunar-volman
cp /etc/ASUS/thunar-volman.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml

#---------------Install thunar-volman and auto mount storage end--------------

# HACK to disable the kernel logo on bootup
#sed -i "/exit 0/i \ echo 3 > /sys/class/graphics/fb0/blank" /etc/rc.local

cp /packages/libmali/libmali-*-x11*.deb /
cp -rf /packages/rkisp/*.deb /
cp -rf /packages/rkaiq/*.deb /
#cp -rf /usr/lib/firmware/rockchip/ /

# reduce 500M size for rootfs
rm -rf /usr/lib/firmware
mkdir -p /usr/lib/firmware/
mv /tmp_firmware/* /usr/lib/firmware/
rm -rf /tmp_firmware

# mark package to hold
apt list --installed | grep -v oldstable | cut -d/ -f1 | xargs apt-mark hold

#---------------Custom Script--------------
systemctl mask systemd-networkd-wait-online.service
systemctl mask NetworkManager-wait-online.service
rm /lib/systemd/system/wpa_supplicant@.service

#-------ASUS customization start-------

echo $VERSION_NUMBER > /etc/version

chmod a+x /etc/init.d/mountboot.sh
systemctl enable mountboot.service

#-------ASUS customization end-------

#-------Tinker board 3: rknn-toolkit_lite2-------
if [ "$VERSION" == "debug" ]; then
        chown -R linaro:linaro /home/linaro/Desktop
	# double click can to execuate the shell script file
	sed -i -e 's/x-shellscript=vim.desktop/x-shellscript=debian-uxterm.desktop/g' /usr/share/applications/mimeinfo.cache
fi

# change owner and permission for install rknn toolkit lite2 script
chown -R linaro:linaro /usr/local/share/debian11_rknn_toolkit_lite2
chmod a+x /usr/local/share/debian11_rknn_toolkit_lite2/debian11_install_rknn_toolkit_lite2.sh
#-------Tinker board 3: rknn-toolkit_lite2-------

#------remove unused packages------------
apt remove --purge -fy linux-firmware*

#---------------Clean--------------
if [ -e "/usr/lib/arm-linux-gnueabihf/dri" ] ;
then
        # Only preload libdrm-cursor for X
        sed -i "1aexport LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libdrm-cursor.so.1" /usr/bin/X
        cd /usr/lib/arm-linux-gnueabihf/dri/
        cp kms_swrast_dri.so swrast_dri.so rockchip_dri.so /
        rm /usr/lib/arm-linux-gnueabihf/dri/*.so
        mv /*.so /usr/lib/arm-linux-gnueabihf/dri/
elif [ -e "/usr/lib/aarch64-linux-gnu/dri" ];
then
        # Only preload libdrm-cursor for X
        sed -i "1aexport LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libdrm-cursor.so.1" /usr/bin/X
        cd /usr/lib/aarch64-linux-gnu/dri/
        cp kms_swrast_dri.so swrast_dri.so rockchip_dri.so /
        rm /usr/lib/aarch64-linux-gnu/dri/*.so
        mv /*.so /usr/lib/aarch64-linux-gnu/dri/
        rm /etc/profile.d/qt.sh
fi
cd -

rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/
rm -rf /packages/


EOF

sudo cp -f overlay/etc/resolv.conf $TARGET_ROOTFS_DIR/etc/

sudo umount $TARGET_ROOTFS_DIR/dev
