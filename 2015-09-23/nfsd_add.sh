#!/bin/bash
#set -x
#by: xingdd
#NFS manager script and auto install environment
#Creat NFS4 server mount point
#This script only use centos 6+ or RedHat 6 + 
baseDir=/data
exPorts=/etc/exports
formatDate=$(date +%Y-%m-%d\ %H:%M:%S)
rpcIdmapd=/etc/idmapd.conf


#user check 
function User_Set(){
	if grep  "nfs" /etc/group >/dev/null ;then
		echo "--Infor: NFS user group  has been exist."
		groupId=$(grep -w "nfs" /etc/group | awk -F':' '{print $3}')
		if id nfsuser >/dev/null 2>&1;then
			echo "--Infor: NFS user has been created."
		else
			echo "--Infor: NFS user not exist."
			echo "--Infor: Start create user."	
			useradd -u 10001 -g ${groupId} nfsuser
		fi
	else
		echo "--Infor: NFS user group not exist."
		echo "--Infor: Start create nfs group."
		groupadd -g 10001 nfs
		if id nfsuser >/dev/null 2>&1;then
			echo "--Infor: Start change user\'s group."
			usermod -g nfs nfsuser
		else
			echo "--Infor: Start create user and specify group"
			useradd -g nfs nfsuser
		fi
	fi

}

#resolve client user "nobody" problems
function setrpcIdmap(){
	if [ -f ${rpcIdmapd} ];then
		echo "--Infor: Start to set rpcidmap."
		sleep 2
		User_Set
		sed -ie 's/^Nobody-User = nobody/Nobody-User = nfsuser/g;s/^Nobody-Group = nobody/Nobody-Group = nfs/g' ${rpcIdmapd}
	else
		echo "--Infor: You did\'t installed rpcbind. please install it. "
		exit 127
	fi
}

# Install NFS Server
function checkEnvironment(){
	if  rpm -qa | egrep "(nfs-utils|rpcbind)" >/dev/null 2>&1;then
		echo "--Infor: NFS Server has been installed."
	else
		echo "--Infor: Start install nfs server."		
		yum install -y nfs-utils rpcbind >/dev/null 2>&1
		if [ $? -eq 0 ];then
			echo "--Infor: NFS Server install sucessfully."
			setrpcIdmap
		else
			echo "--Infor: NFS Server install failure."
		fi
	fi
}
#restart server
function serManager(){
	/etc/init.d/rpcidmapd restart
	/etc/init.d/rpcbind restart
	/etc/init.d/nfs restart
        return 0
}

function useridset () {
	if [ $1 == 'root' ];then

		if id nfsnobody >/dev/null 2>&1;then
			NFSUID=$(grep nfsnobody /etc/passwd | awk -F':' '{print $3}')
			NFSGID=$(grep nfsnobody /etc/passwd | awk -F':' '{print $4}')
			echo "# $1 share point build date ${formatDate} " >>${exPorts}
			echo "$baseDir/$Dir $Addr(rw,async,no_root_squash,anonuid=${NFSUID},anongid=${NFSGID},insecure)" >>${exPorts}
		else
			NFSUID=2001
			NFSGID=2001
			grouadd -g $NFSGID nfsnobody
			useradd -g $NFSGID -M -s /sbin/nologin -u $NFSUID nfsnobody
			echo  nfsnobody:'FUCKabc' | chpasswd
			echo "# $1 share point build date ${formatDate} " >>${exPorts}
			echo "$baseDir/$Dir $Addr(rw,async,no_root_squash,anonuid=${NFSUID},anongid=${NFSGID},insecure)" >>${exPorts}
			
		fi
	elif [ $1 == 'nfsuser' ];then
		
		if id nfsnobody >/dev/null 2>&1;then
			NFSUID=$(grep nfsnobody /etc/passwd | awk -F':' '{print $3}')
			NFSGID=$(grep nfsnobody /etc/passwd | awk -F':' '{print $4}')
			echo "# $1 share point build date ${formatDate}" >>${exPorts}
			echo "$baseDir/$Dir $Addr(rw,async,all_squash,anonuid=${NFSUID},anongid=${NFSGID},insecure)">>${exPorts}
		else
			NFSUID=2001
			NFSGID=2001
			grouadd -g $NFSGID nfsnobody
			useradd -g $NFSGID -M -s /sbin/nologin -u $NFSUID nfsnobody
			echo  nfsnobody:'FUCKabc' | chpasswd
			echo "# $1 share point build date ${formatDate} " >>${exPorts}
			echo "$baseDir/$Dir $Addr(rw,async,all_squash,anonuid=${NFSUID},anongid=${NFSGID},insecure)">>${exPorts}
		fi
		
	else
		echo "--Infor: Fuck your father 。Don\'t running it like this."
	fi

}


#create a mount public point
function creatPoint(){
	read -p "--Infor: Please enter a server point directory like abcdirectory:" Dir
	read -p "--Infor: Please enter a user for client [root|nfsuser]:" InUser
	read -p "--Infor: please enter a client ip or subip like [192.168.1.100|192.168.1.0/24]" Addr
	if [ -d $baseDir/$Dir ];then
		echo "--Infor: Your enter poin has been exist"
		exit 1
	else
		echo "--Infor: Start create mount point "
		mkdir -pv $baseDir/$Dir
		if [ $InUser == "root" ];then
			if grep -w "$Dir" $exPorts > /dev/null 2>&1;then
				echo "--Infor: NFS has been set share public point."
				exit 0
			else
				useridset $InUser
				if serManager >/dev/null 2>&1;then
					exportfs -rv
				else
					echo "--Infor: NFS Server start failed!"
				fi
			fi
		elif [ $InUser == "nfsuser" ];then
			if grep -w "$Dir" $exPorts > /dev/null 2>&1;then
				echo "--Infor: NFS has been set share public point."
				exit 0
			else
				useridset $InUser
				if serManager >/dev/null 2>&1;then
					exportfs -rv
				else
					echo "--Infor: NFS Server start failed!"
				fi
			fi
		else
			clear 
			echo "#############################################"
			echo "--Infor: Don\'t fuck use other user build NFS"
			echo "#############################################"
		fi
	fi	
}

case $1 in
	-c|--create)
			creatPoint
		;;
	-r|--restart)
			serManager
		;;
	-i|--install)
			checkEnvironment
		;;
	--help|*)
			echo "Usage: sh $0 --help "
			echo "    -c|--create  Create nfs share point."
			echo "    -r|--restart Restart nfs server."
			echo "    -i|--install Install nfs server"
esac
