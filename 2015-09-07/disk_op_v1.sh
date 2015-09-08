#!/bin/bash
#auth:xingdd
#mail:osx1260@163.com
Dis_values=$(fdisk -l | egrep "xvdb" | wc -l)
Fs_values=$(grep data /etc/fstab | wc -l)
Mouned_values=$(mount -l | grep xvdb | wc -l)

#Delete old filesystem 
Deleteformat() {
if [ -d /data ];then
    umount /data
fdisk /dev/xvdb<<EOF
d
w
EOF
else
    echo "--waring:Not unmount filesystem"
fdisk /dev/xvdb<<EOF
d
w
EOF
fi
}

#Reformat disk 
Reformat() {
fdisk /dev/xvdb<<EOF 
n
p
1


w
EOF
}
# disk format
formatmethod(){
    if [ "${Dis_values}" -eq "2" ];then
        clear 
        echo "--The disk has been format "
        read -p "--Are sure reformat the /xvdb filesystem?[(y|Y)|(n|N)]" EnterValues
        Revalues=$(echo $EnterValues | tr '[A-Z]' '[a-z]')
        if [ $Revalues == "y" ];then
            echo "--Warning: this operation will delete all your data."
            sleep 5
            echo "--Start to format your disk."
            sleep 5
            Deleteformat >/dev/null 2>&1 
            Reformat >/dev/null 2>&1
            if [ $? -eq 0 ];then
                echo "--Congratulation: Format successful."
            else
                echo "--Error: Format failure."
            fi
        elif [ $Revalues == "n" ];then
            clear
            echo "--Script executive stop and will exit "
            sleep 5
            exit  0
        fi
    elif [ "${Dis_values}" -eq "1" ];then
        clear
        echo "--Start to format your disk"
        sleep 5
        Reformat >/dev/null 2>&1
        if [ $? -eq 0 ];then
            echo "--Congratulation: Format successful."
        else
            echo "--Error: Format failure."
        fi
    else
        clear
        echo "--This script is not Applicable this system operation"
    fi
}
check_mounted() {
   if [ "${Mouned_values}" -eq "1" ];then
       echo "--The disk has been mounted."
       exit 0
   elif [ "${Mouned_values}" -eq "0" ];then
       mount /dev/xvdb1 /data/
       echo "--Finished mounted."
   fi
}





mkfs_ext4() {
           mkfs.ext4 /dev/xvdb1 > /dev/null 2>&1
           check_mounted 
           if [ "$Fs_values" -eq "1" ];then
               echo "--Warning fstab file has been set."
           elif [ "$Fs_values" -eq "0" ];then
               echo "--Start set fstab file."
               echo '/dev/xvdb1      /data   ext4    defaults,barrier=0 1 1' >>/etc/fstab
           fi
}
mouted() {
    if [ -d /data ];then
       if [ "${Dis_values}" -eq "2" ];then
          mkfs_ext4 
          formatmethod
       else
          echo "--Waring:Your disk is not format."
          sleep 5
          formatmethod
          mkfs_ext4
       fi
    else
       mkdir /data
       if [ "${Dis_values}" -eq "2" ];then
           mkfs_ext4 
          formatmethod
       else
          echo "--Waring:Your disk is not format."
          sleep 5
          formatmethod
          mkfs_ext4
       fi
       
    fi
}

mouted
