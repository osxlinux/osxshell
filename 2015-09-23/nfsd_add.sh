#!/bin/bash
#by:xingdd
#NFS manager script
#Creat NFS4 server mount point
baseDir=/data
exPorts=/etc/exports
formatDate=$(date +%Y-%m-%d\ %H:%M:%S)

read -p "--Infor: Please enter a server point directory:" Dir
read -p "--Infor: Please enter a user for client [root|nfsuser]:" InUser
read -p "--Infor: please enter a client ip or subip like [192.168.1.100|192.168.1.0/24]" Addr


#create a mount public point
function creatPoint(){
	if [ -d $baseDir/$Dir ];then
		echo "--Infor: Your enter poin has been exist"
		exit 1
	else
		echo "--Infor: Start create mount point "
		mkdir $baseDir/$Dir
		if [ $InUser == "root" ];then
			if grep -w "$Dir" $exPorts > /dev/null 2>&1;then
				echo "--Infor: NFS has been set share public point."
			else
				echo "#root share point build date ${formatDate} " >>${exPorts}
				echo "$baseDir/$Dir $Addr(rw,async,no_root_squash,anonuid=10001,anongid=10001,insecure)" >>${exPorts}
			fi
		elif [ $InUser == "nfsuser" ];then
			if grep -w "$Dir" $exPorts > /dev/null 2>&1;then
				echo "--Infor: NFS has been set share public point."
			else
				echo "#root share point build date ${formatDate}" >>${exPorts}
				echo "$baseDir/$Dir $Addr(rw,async,all_squash,anonuid=10001,anongid=10001,insecure)">>${exPorts}
			fi
		else
			clear 
			echo "#############################################"
			echo "--Infor: Don\'t fuck use other user build NFS"
			echo "#############################################"
		fi
	fi	
}

#restart server
function serManager(){
	/etc/init.d/rpcidmapd restart
	/etc/init.d/rpcbind restart
	/etc/init.d/nfs restart
}
creatPoint
