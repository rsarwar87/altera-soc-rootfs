# Build Altera SoC Image with Ubuntu

This repository includes an Ubuntu 18.04.1 base with several development packages pre-installed. It is based on DE10-nano using HDMI framebuffer. It can be easily updated to address any altera/xilinx board.

* There are five steps to build Altera SoC image with Ubuntu.
1. <a href="#1-establish-cross-compile-environment">Establish Cross-compile environment</a>
2. <a href="#2-build-fpga-project">Build FPGA Project to update device tree</a>
3. <a href="#3-linux-filesystem">Modifications made to Ubuntu base filesystem</a>
4. <a href="#4-build-linux-kernel">Build Linux Kernel</a>
5. <a href="#5-create-linux-image-file">Create Linux Image File</a>

* The following scripts aims to automate some of these steps.
1. download_rootfs.sh -- Download and prepare root file system.
2. update_rootfs.sh -- Update file system with standard tools
3. prepare_devicetree.sh -- compiles device hardware information and places them according to requirement. Please ensure that 2.2 Quartus Setup is followed.
4. prepare_sdcard.sh -- prepares sd_card image assuming a 16 GB storage medium. 


## 1. Establish Cross-compile environment
This chapter describe how to establish a cross-compile environment on Linux. Please follow the instruction from the sections below to install the required software and finally create an empty project folder for building the project later.

<div style="margin-left: 20px;">

1.1 <a href="#11-install-ubuntu-16041-64bits-on-pc">Install Ubuntu 18.04.1 64-bit</a>
1.2 <a href="#12-install-quartus-prime-standard-edition-1602">Install Quartus Prime Standard Edition 18.1</a>
1.3 <a href="#13-install-soc-eds-tool">Install SoC Embedded Design Suite 18.1</a>
1.4 <a href="#14-install-arm-linux-gnueabihf-toolchain">Install Linaro Cross Compiler: arm-linux-gnueabihf 5.2 (for ubuntu 16) or 7.3 (for ubuntu 18)</a>
1.5 <a href="#15-install-library-amp-tool">Install Library and Tool</a>
1.6 <a href="#16-directory-structure">Directory structure</a>
</div>

### 1.1 Install Ubuntu 64-bit on the Host PC
A 64-bit Ubuntu is required to establish a compile environment. Please download the Ubuntu image file and install it on your 64-bit Intel/AMD PC with the following instructions. 

* Download [Ubuntu 18.04.1 64-bit](http://releases.ubuntu.com/18.04.1/ubuntu-18.04.1-desktop-amd64.iso)
* Download [Ubuntu 16.04.1 64-bit](http://releases.ubuntu.com/16.04.1/ubuntu-16.04.1-desktop-amd64.iso)
* [Install Ubuntu on the Host PC](https://www.ubuntu.com/download/desktop/install-ubuntu-desktop)

### 1.2 Install Quartus Prime Standard Edition 18.0
Altera Quartus is required to compile FPGA project. Please follow the instruction below to download and install Quartus Prime, Cyclone V device and the patch on Ubuntu.

* Download and install [Quartus Prime Standard Edition](http://dl.altera.com/18.1/?edition=standard&platform=linux#tabs-2) and [Cyclone V device support](http://dl.altera.com/18.1/?edition=standard&platform=linux#tabs-2)
  
### 1.3 Install SoC EDS tool
Altera SoC EDS tool is required to compile ARM project. Please follow the instructions below to install the EDS tool. 
:::info
Note: Altera DS-5 is not required for the installation.
:::

* Download and install the [SoC EDS tool](http://dl.altera.com/soceds/18.1/?platform=linux)

### 1.4 Install arm-linux-gnueabihf Toolchain
ARM toolchain is required to cross-compile ARM project. Please type the following commands in Ubuntu Terminal to install the required ARM toolcahin.
```shell
#for Ubuntu 16.04.1
cd /opt
sudo wget -c https://releases.linaro.org/components/toolchain/binaries/5.2-2015.11-2/arm-linux-gnueabihf/gcc-linaro-5.2-2015.11-2-x86_64_arm-linux-gnueabihf.tar.xz
sudo tar xvf gcc-linaro-5.2-2015.11-2-x86_64_arm-linux-gnueabihf.tar.xz
sudo ln -s gcc-linaro-5.2-2015.11-2-x86_64_arm-linux-gnueabihf arm-linux-guneabihf
export PATH=$PATH:/opt/arm-linux-guneabihf/bin
```
```shell
#for Ubuntu 18.04.1
cd /opt
sudo wget -c https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/arm-linux-gnueabihf/gcc-linaro-7.3.1-2018.05-i686_arm-linux-gnueabihf.tar.xz
sudo tar xvf gcc-linaro-7.3.1-2018.05-i686_arm-linux-gnueabihf.tar.xz
sudo ln -s gcc-linaro-7.3.1-2018.05-i686_arm-linux-gnueabihf.tar.xz arm-linux-guneabihf
export PATH=$PATH:/opt/arm-linux-guneabihf/bin
```


### 1.5 Install Library and Tool
Some library and tool are required to perform cross-compiler for ARM project. Please type the following commands in Ubuntu Terminal to install the required library and tool.
```shell
sudo apt install lib32ncurses5 qemu-user-static git pv libncurses5-dev -y
```

### 1.6 Directory Structure
Folder tree is established to store the source code for compilation. The folder tree looks like the example below:
```
de10_nano/
├── image
│   ├── p1
│   ├── p2
│   └── p3
├── ghrd
├── linux-socfpga
└── rootfs
```
## 2. Build FPGA Quartus Project

This chapter describes how to build the FPGA configure file (soc_system.rbf), preloader(preloader-mkpimage.bin), u-boot(u-boot.img), and device tree blob(soc_system.dtb). 

Please type the following commands in Ubuntu Terminal for building the FPGA project in Quartus Prime Standard edition. 

### 2.1 Prepare Project

* Download and extract the DE10-NANO-FB FPGA Quartus project from Tersic's website.

### 2.2 Quartus Setup
* Setting environment variable
```shell
~/altera/16.0/embedded/embedded_command_shell.sh
```

### 2.3 Build Project
* Generate Components
Type the following commands to generate all components including preloader-mkpimage.bin, u-boot.img, soc_system.dtb, soc_system.rbf, and u-boot.scr.
```shell
make all
```

* Copy Components
Type the following commands to copy the generated components to a dedicated folder for building an image.
```shell
cp output_files/soc_system.rbf ../image/p1/output_files/
cp soc_system.dtb ../image/p1/
cp u-boot.scr ../image/p1/
cp software/preloader/preloader-mkpimage.bin ../image/p3/
cp software/preloader/uboot-socfpga/u-boot.img ../image/p3/
```

## 3. Build Linux Filesystem
This chapter describes modifications that were made to the Linux tool filesystem. The final filesystem is stored in the folder "~/de10_nano/rootfs". 

Type the following commands in Ubuntu Terminal for building the Linux Filesystem. 

* Switch to root privilege
```shell
sudo -s
```

* Download the Ubuntu root filesystem 
```shell
cd ~/de10_nano/rootfs
wget -c http://cdimage.ubuntu.com/ubuntu-base/releases/18.04.1/release/ubuntu-base-18.04-base-armhf.tar.gz
tar xvf ubuntu-base-18.04-base-armhf.tar.gz
rm ubuntu-base-18.04-base-armhf.tar.gz
```

* Copy qemu-user-static
```shell
cp /usr/bin/qemu-arm-static usr/bin/
```

* Modify `etc/apt/sources.list` to un-comment all the repositories except the ones starting with `deb-src`.
```shell
sed -i 's%^# deb %deb %' etc/apt/sources.list
```

* copy your system’s (host machine’s) `/etc/resolv.conf` to `~/de10_nano/rootfs/etc/resolv.conf`. Set proxies if necessary.
```shell
cp /etc/resolv.conf rootfs/etc/resolv.conf
```

* Mounting the filesystem with chroot using the script below and un-mounting later.
```shell
wget https://raw.githubusercontent.com/psachin/bash_scripts/master/ch-mount.sh
```

* Mount `proc, sys, dev, dev/pts` to the new filesystem. 
```shell
chmod a+x ch-mount.sh
./ch-mount.sh -m rootfs/
```

* Update the repositories
```shell
chmod 1777 /tmp
apt update
```

* Install minimal packages required for core utils
```shell
apt install language-pack-en-base sudo ssh net-tools ethtool iputils-ping rsyslog alsa-utils bash-completion htop python-gobject-2 network-manager ntp build-essential python3--no-install-recommends usbutils psmisc lsof unzip udev net-tools netbase ifupdown network-manager lsb-base nginx vim cmake --yes
```

* Add /usr/local/koheron-server to the environment PATH
```shell
cat <<- EOF_CAT > etc/environment
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/koheron-server"
EOF_CAT
```

* Update hostname, user profile
```shell
echo koheron-altera > etc/hostname

cat <<- EOF_CAT >> etc/hosts
127.0.0.1    localhost.localdomain localhost
127.0.1.1    koheron-altera
EOF_CAT

cat <<- EOF_CAT >> etc/network/interfaces
allow-hotplug eth0
# DHCP configuration
iface eth0 inet dhcp
# Static IP
#iface eth0 inet static
#  address 192.168.1.100
#  gateway 192.168.1.1
#  netmask 255.255.255.0
#  network 192.168.1.0
#  broadcast 192.168.1.255
  post-up systemctl start koheron-server-init
EOF_CAT

useradd rsarwar 
passwd rsarwar
addgroup rsarwar sudo && addgroup rsarwar audio && addgroup rsarwar video
mkdir -p /home/rsarwar
chsh -s /bin/bash


cat <<- EOF_CAT >> /home/rsarwar/.bash_profile
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF_CAT

cat <<- EOF_CAT >> /home/rsarwar/.bashrc
PS1="\[\033[01;32m\]\u@\h\[\033[00m\] : \[\033[01;34m\]\w\[\033[00m\]\n\$ " 
EOF_CAT
systemd-machine-id-setup
```


* Install packages required for LXDE Desktop
```shell
apt install lxde xfce4-power-manager xinit xorg lightdm-gtk-greeter xserver-xorg-video-fbdev gnome-mplayer lightdm lxtask htop --yes
```

* Exit chroot and unmount `proc, sys, dev, dev/pts`
```shell
exit
./ch-mount.sh -u rootfs/
```

* Return to user privilege
```shell
exit
```

Reference: [Building Ubuntu rootfs for ARM](https://gnu-linux.org/building-ubuntu-rootfs-for-arm.html)
Reference: [Koheron-sdk](https://github.com/Koheron/koheron-sdk/blob/master/os/scripts/ubuntu-production.sh)

## 4. Build Linux Kernel
This chapter describes how to build Linux kernel.The final kernal image is stored in the directory `~/de10_nano/image/p1`. The kernel module is stored in the directory `~/de1_soc/rootfs`.

Type the following commands in Ubuntu Terminal for building the Linux kernel. 

* Download the source code of the kernel
```shell
cd ~/de10_nano
git clone https://github.com/altera-opensource/linux-socfpga.git
cd linux-socfpga
git checkout -t -b socfpga-4.5 origin/socfpga-4.5
```

* Setup enviroment variables for cross-compilation
```shell
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
```

* Generate the default config. file `.config`
```shell
make socfpga_defconfig
```

* Kernel configuration


    ```shell
    make menuconfig
    ```
  * Enable Frame Reader framebuffer support
    ```
    Device Drivers  --->
      Graphics support  --->
        Frame buffer Devices  --->
          <*> Support for frame buffer devices  --->
          <*> Altera VIP Frame Reader framebuffer support
    ```

  * Enable UVC Camera support
    ```
    Device driver-->
      <*>Multimedia support-->
        [*]Cameras/video grabbers support
        [*]Media USB Adapters-->
          <*>USB Video Class(UVC)
            [*]UVC input event device support
    ```
    
    > Move cursor to 「Media USB Adapters-->」,then press 'Enter' to enter the submenu.
* Save config and exit 

* Compile kernel
```shell
make zImage -j10
```

* Copy kernel
```shell
cp arch/arm/boot/zImage ~/de10_nano/image/p1/
```

* Compile modules
```shell
make modules -j10
```

* Install modules
```shell
sudo -E make modules_install INSTALL_MOD_PATH=~/de10_nano/rootfs/
```

## 5. Create Linux Image File
This chapter describes how to merge the components generated in above chapters into an image file. It also shows how to write this image file into a microSD card. 


The Python script file 'make_sdimage2.py' provided from rocketboards.org can be used to merge these components. Execute the script file
Type the following commands in terminal to execute the script file and merge all components into a single image file 'de1-soc-sd-card.img'
```shell
## for 16 GB images
sudo ./make_sdimage.py -f \
     -P p1/*,num=1,format=vfat,size=500M \
     -P p2/*,num=2,format=ext3,size=13500M \
     -P p3/preloader-mkpimage.bin,p3/u-boot.img,num=3,format=raw,size=10M,type=A2 \
     -s 14200M \
     -n de10-nqno-sd-card.img
     
## for 4 GB images
sudo ./make_sdimage.py -f \
     -P p1/*,num=1,format=vfat,size=100M \
     -P p2/*,num=2,format=ext3,size=3500M \
     -P p3/preloader-mkpimage.bin,p3/u-boot.img,num=3,format=raw,size=10M,type=A2 \
     -s 3700M \
     -n de10-nqno-sd-card.img
```


* Clone the image to the microSD card
Insert a microSD card (at least 4GB is required and 8GB is recommended) into your host PC. Execute the following commands to clone the image file. 
Note the "sd<span style="color: red">x</span>" in the command below needs to be replaced with the device name of the microSD card on your host PC. The `lsblk` command can be used to check the device name associated with the inserted microSD card.

```shell
umount /dev/sdx* 2> /dev/null
pv -tpreb de1-soc-sd-card.img | sudo dd of=/dev/sdx bs=1M
```

# Appendix

## Contents of the microSD Card Image in Linux 
### Partition Format
There are three partitions in microSD Card
* FAT32
* EXT3
* RAW A2
### Partition Content
#### FAT32
* Device tree blob
* FPGA configuration
* U-boot script for FPGA configuration
* Linux kernel image
#### EXT3
* Filesystem
#### RAW A2
* Preloader image
* U-boot image

:::info
The order of the partitions cannot be changed. 
:::


## Update Individual Elements on the microSD Card
It is time consuming to write the entire image to the microSD card whenever a modification is made. Hence it is preferred to update the elements individually after the first image is created and written to the microSD card. 

The following table shows how each item can be updated individually.

<table>
    <tr>
        <th>Item</th>
        <th>Update Procedure</th>
    </tr>
    <tr>
        <td>zImage</td>
        <td rowspan="4">Mount partition 1 from the microSD card and replace the file with the new one.<br><code>mkdir sdcard</code> <br><code>mount /dev/sdx1 sdcard/</code><br><code>cp &lt;file_name&gt; sdcard/</code><br><code>umount sdcard</code></td>
    </tr>
    <tr>
        <td>soc_system.rbf</td>
    </tr>
    <tr>
        <td>soc_system.dtb</td>
    </tr>
    <tr>
        <td>u-boot.scr</td>
    </tr>
    <tr>
        <td>preloader-mkpimage.bin</td>
        <td>dd if=preloader-mkpimage.bin of=/dev/sdx3 bs=64k seek=0</td>
    </tr>
    <tr>
        <td>u-boot.img</td>
        <td>dd if=u-boot.img of=/dev/sdx3 bs=64k seek=4</td>
    </tr>
    <tr>
        <td>filesystem</td>
        <td>dd if=de1-soc-sd-card.img bs=512 skip=206849 count=7168001 | pv -tpreb -s 3500m | sudo dd of=/dev/sdx2 bs=512</td>
    </tr>
</table>

Remember to replace "sdx" in the command above with the device name of the microSD card on your host PC. You can find out the device name by executing `cat /proc/partitions` after plugging in the card reader into the host.

Reference: [GSRD v15.1 - microSD Card - Arrow SoCKit Edition](https://rocketboards.org/foswiki/view/Documentation/GSRD151SDCardArrowSoCKitEdition)

