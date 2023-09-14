#!/bin/sh
# Copyright (c) 2014, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# find_partitions        init.d script to dynamically find partitions
#

FindAndMountUBI () {
   partition=$1
   dir=$2

   #Foxconn, Jacky Kao modified (start), 2016/02/02 --- To avoid finding same partition name twice
   #mtd_block_number=`cat $mtd_file | grep -i $partition | sed 's/^mtd//' | awk -F ':' '{print $1}'`
   #mtd_block_number=`cat $mtd_file | grep -i "\"$partition\"" | sed 's/^mtd//' | awk -F ':' '{print $1}'`
   mtd_block_number=`cat $mtd_file | grep -w "\"$partition\"" | sed 's/^mtd//' | awk -F ':' '{print $1}'`
   #Foxconn, Jacky Kao modified (end), 2016/02/02 --- To avoid finding same partition name twice

   echo "MTD : Detected block device : $dir for $partition"
   mkdir -p $dir

   ubiattach -m $mtd_block_number -d 1 /dev/ubi_ctrl
   device=/dev/ubi1_0
   while [ 1 ]
    do
        if [ -c $device ]
        then
### Foxconn modify start, Min-Chang, for the property of /firmware/* , 01-28-2016
            mount -t ubifs -o ro /dev/ubi1_0 $dir -o bulk_read
#            mount -t ubifs /dev/ubi1_0 $dir -o bulk_read
### Foxconn modify end, Min-Chang, for the property of /firmware/* , 01-28-2016
            break
        else
            sleep 0.010
        fi
    done
}

FindAndMountVolumeUBI () {
   volume_name=$1
   dir=$2
   if [ ! -d $dir ]
   then
       mkdir -p $dir
   fi
   mount -t ubifs ubi0:$volume_name $dir -o bulk_read
}
##Foxconn add start, Wen-Fei 2016-11-10 recovery Foxuser partition
FormatFoxUserUBI () {
##ubidetach -d 2 # if ecc error in foxuser ubi, this command will stuck. 
  ubidetach -m 20
  ubiformat /dev/mtd20 -y
  ubiattach -m 20 -d 2 /dev/ubi_ctrl
  ubimkvol /dev/ubi2 -s 4MiB -n 0 -N foxfs
  mount -t ubifs /dev/ubi2_0 /foxusr
}
##Foxconn add end, Wen-Fei 2016-11-10 recovery Foxuser partition
##Foxconn add start, S.K.Yang 2016/04/01 Make Foxuser partition
FindAndMountFOXVolumeUBI () {
	 partition=$1
   dir=$2
##Foxconn add start, Wen-Fei 2016-11-10 recovery Foxuser partition
   counter=0
##Foxconn add end, Wen-Fei 2016-11-10 recovery Foxuser partition

   mtd_block_number=`cat $mtd_file | grep -w "\"$partition\"" | sed 's/^mtd//' | awk -F ':' '{print $1}'`

   echo "MTD : Detected block device : $dir for $partition"
   #mkdir -p $dir

   ubiattach -m $mtd_block_number -d 2 /dev/ubi_ctrl
   device=/dev/ubi2_0
   while [ 1 ]
    do
        if [ -c $device ]
        then
            echo "WSNDEBUG: wait count = $counter" >> /dev/kmsg
            foxusr_error_count=`cfg -v FOXUSR_ERROR`
            if [ ${foxusr_error_count} -ge 1 ]; then
				cfg -a FOXUSR_ERROR=0
				cfg -c
            fi
            mount -t ubifs /dev/ubi2_0 $dir
            break
        else
#            echo "==========sleep due to foxfs volume (/dev/ubi2_0) is not ready========="
            sleep 0.010
##Foxconn add start, Wen-Fei 2016-11-10 recovery Foxuser partition
            counter=$(( $counter + 1 ))
            if [ ${counter} -ge 600 ]; then
            	foxusr_error_count=`cfg -v FOXUSR_ERROR`
            	foxusr_error_count=$(( $foxusr_error_count + 1 ))
            	echo "WSNDEBUG: foxusr_error_count = $foxusr_error_count"
            	if [ ${foxusr_error_count} -gt 3 ]; then
	            	echo "$counter: ===========format foxuser UBI==================" >> /dev/kmsg
	            	FormatFoxUserUBI
	                break
	            else
	            	echo "===========foxuser UBI mount fail - reboot=================="
	            	cfg -a FOXUSR_ERROR=$foxusr_error_count
	            	cfg -c
	            	reboot
	            	break
	            fi
            fi
##Foxconn add end, Wen-Fei 2016-11-10 recovery Foxuser partition
        fi
    done
}
##Foxconn add end, S.K.Yang 2016/04/01 Make Foxuser partition

mtd_file=/proc/mtd

fstype="UBI"
#Foxconn marked, wen-fei, 2016-08-24 for no usrfs volume data
#eval FindAndMountVolume${fstype} usrfs /data

eval FindAndMount${fstype} modem /firmware

eval FindAndMountFOXVolume${fstype} foxusr /foxusr
exit 0
