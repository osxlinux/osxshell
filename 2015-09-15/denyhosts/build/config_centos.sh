#!/bin/bash
SYSCON=/etc/syslog.conf
RSYSCON=/etc/rsyslog.conf
CHAGE=$(cat /etc/ssh/sshd_config | grep "^SyslogFacility" | awk '{print $2}')
sed -i "/SyslogFacility/s#$CHAGE#local5#" /etc/ssh/sshd_config
sed -i 's/^#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
if [ -f $SYSCON ];then
	UNICO=''
	echo "Warging:The log software is syslog "
	UNICO=$(cat /etc/syslog.conf | grep "sshd.log" | awk 'NR==1{print $1}')
if [ -z $UNICO ];then
cat >>$SYSCON<<EOF
#save the login info as sshd.log
local5.*	/var/log/sshd.log
EOF
	/etc/init.d/sshd restart
	/etc/init.d/syslog restart
	[ -f /var/log/sshd.log ]  && echo "Config the syslog of ssh info as sshd.log sucessful...."
else
	echo "The configuration of the sshd log file end"
fi
elif [ -f $RSYSCON ];then
		UNICO=''
	        echo "The log software is rsyslog "
	UNICO=$(cat /etc/rsyslog.conf | grep "sshd.log" | awk 'NR==1{print $1}')
if [ -z $UNICO ];then
cat >>$RSYSCON<<EOF
#save the login info as sshd.log
local5.*	/var/log/sshd.log
EOF
	/etc/init.d/sshd restart
	/etc/init.d/rsyslog restart
	[ -f /var/log/sshd.log ]  && echo "Config the syslog of ssh info as sshd.log sucessful...."
else
	echo "The configuration of the sshd log file end"
fi
fi
