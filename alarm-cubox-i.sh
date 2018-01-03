#!/bin/bash

read -p "enter the device to install arch linux arm on: " dev

umount /dev/$dev*
mkfs.vfat /dev/$dev
dd if=/dev/zero of=/dev/$dev bs=1M counts=4
fdisk /dev/$dev <<EOF
o
n
 
 

 
w 
EOF

mkfs.ext4 /dev/"$dev"1 <<EOF
y
EOF

if [ ! -d alarm-cubox-i-temp ]; then
  mkdir alarm-cubox-i-temp
  mkdir root
fi

cd alarm-cubox-i-temp
mount /dev/"$dev"1 root

if [ ! -f ArchLinuxARM-imx6-cubox-latest.tar.gz ]; then
  wget http://os.archlinuxarm.org/os/ArchLinuxARM-imx6-cubox-latest.tar.gz
fi

unarchive="$(tar -xf ArchLinuxARM-imx6-cubox-latest.tar.gz -C root 2>/dev/null)"

$unarchive || apt-get install -y tar && $unarchive

if [ -d root/boot ]; then
  dd if=root/boot/SPL of=/dev/$dev bs=1K seek=1
  dd if=root/boot/u-boot.img of=/dev/$dev bs=1K seek=69
  sync
  umount boot
  umount /dev/$dev*
else
  echo " no boot! "
fi

