#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. Needs two parameters: version (i.e. 18.04) and name of director"
fi

dir = $2
version = $1
path ?= http://cdimage.ubuntu.com/ubuntu-base/releases/${version}/release/ubuntu-base-${version}.1-base-armhf.tar.gz

mkdir ${dir}
rm $PWD/image/p2
ln -sf $PWD/${dir} $PWD/image/p2
cd ${dir}

sudo -s

wget -c ${path}
tar xvf ubuntu-base-${version}-base-armhf.tar.gz
rm ubuntu-base-${version}-base-armhf.tar.gz

cp /usr/bin/qemu-arm-static usr/bin/
sed -i 's%^# deb %deb %' etc/apt/sources.list
cp /etc/resolv.conf rootfs/etc/resolv.conf

cd ..

exit

