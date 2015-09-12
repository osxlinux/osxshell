#!/bin/bash
#AUTH:seraph
#Email:osx1260@163.com
#By:xingyaodong
FIEX=''
PWDIR=$(pwd)
FIEX=$(cat /etc/rc.local | grep denyhosts | awk '{print $2}')
PREDENY=/usr/share/denyhosts
CHECKNAME=$(sh check_os.sh)
echo "Your Operating System is $CHECKNAME "
OSNA=$(echo $CHECKNAME | awk '{print $1}')
case $OSNA in
	CentOS)
	bash $PWDIR/build/config_centos.sh
	;;
	Ubuntu)
	bash $PWDIR/build/config_ubuntu.sh
	;;
	SUSE)
	bash $PWDIR/build/config_suse.sh
	;;
	*)
	echo "This script is not run this OS"
esac

if [ -d ${PREDENY} ];then
	echo "Then Denyhosts has been installed"
	exit 0
fi
tar -zxf DenyHosts-2.6.tar.gz >/dev/null 2>&1
cd DenyHosts-2.6
python setup.py install >/dev/null 2>&1
if [ $? -eq 0 ];then
	echo "Install DenyHosts sucessfull "
else
	echo "Please check python version"
fi


cp $PWDIR/build/daemon-control /usr/share/denyhosts/
cp $PWDIR/build/denyhosts.cfg /usr/share/denyhosts/
cp $PWDIR/build/denyhosts.py /usr/bin/denyhosts.py
chown root /usr/share/denyhosts/daemon-control
chmod 755 /usr/bin/denyhosts.py
chmod 700 /usr/share/denyhosts/daemon-control
if [ -f /etc/rc.local ];then
	FIEX=$(cat /etc/rc.local | grep denyhosts | awk '{print $2}' | wc -l)
	if [ $FIEX -eq 1 ];then
	echo "has been config start denyhosts"
	else
	echo "/usr/share/denyhosts/daemon-control start" >>/etc/rc.local
	fi
fi
if [ -f /usr/share/denyhosts/denyhosts.cfg ];then
	echo "Denyhost.cfg has been set. "
else
	cp $PWDIR/build/denyhosts.cfg /usr/share/denyhosts/
fi
cd /etc/init.d
ln -s /usr/share/denyhosts/daemon-control denyhosts
case $OSNA in
	CentOS)
		chkconfig --add denyhosts
		chkconfig --level 345 denyhosts on
		service denyhosts restart
		;;
	SUSE)
		chkconfig --add denyhosts
                chkconfig --level 345 denyhosts on
                service denyhosts restart
		;;
	Ubuntu)
		update-rc.d denyhosts defaults
		/etc/init.d/denyhosts start
		;;
	*)
		echo "##Error: unrech os system  "
esac
