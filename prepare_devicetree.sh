#!/bin/bash

cd ghrd
make all

cp output_files/soc_system.rbf ../image/p1/output_files/
cp soc_system.dtb ../image/p1/
cp u-boot.scr ../image/p1/
cp software/preloader/preloader-mkpimage.bin ../image/p3/
cp software/preloader/uboot-socfpga/u-boot.img ../image/p3/

cd ..
