#!/bin/bash
#
#Usage: use set zabbix monitor salt process install script
sPath=$(pwd)
zPort=10050
zPath=/usr/local/zabbix
zInit=/etc/init.d/zabbix_agentd
zExpath=/usr/local/zabbix/etc/zabbix_agentd.conf.d
zExternalpath=/usr/local/zabbix/share/zabbix/externalscripts
zProcess=$(lsof -i:10050 | egrep "^(zabbix_ag|zabbix-agent)" | wc -l)
zPsprocess=$(ps -ef | grep zabbix_agentd | egrep -v "(grep|$0)" | wc -l)

# zabbix current status
function zStatus(){
	if [[ ${zPsprocess} -ge 1 && ${zProcess} -ge 1 ]];then
		echo "--Information: zabbix running ......"
	else
		if [ -L $zPath ];then
			echo "--Information: zabbix not running."
		else
			echo "--Information: zabbix is not installed."
            exit 127
		fi
	fi
	
}

# set check saltstack environment
function setSalt(){
	if [[ -d ${zExpath} && -d ${zExternalpath} ]];then
		test ! -f $zExpath/check_salt.conf && cp -r $sPath/config/check_salt.conf $zExpath	
        test ! -f $zExternalpath/salt_status.sh && cp -r $sPath/config/salt_status.sh $zExternalpath
        test ! -f $zExternalpath/record.sh && cp -r $sPath/config/record.sh  $zExternalpath
		chown -R zabbix:zabbix $zExternalpath/salt_status.sh
		chmod -R 755 $zExternalpath/salt_status.sh
		chmod -R 755 $zExternalpath/record.sh
		echo "--Information: File has been set."
    else
		echo "--Information: Don't set environment."
	fi

}
function setCrontab(){
	if [ -f $zExternalpath/record.sh ];then
		echo "--Information: Start add  crontab task."
		crontab -l >/tmp/oldcrontab.tmp
        HasExist=$(cat /tmp/oldcrontab.tmp | grep Saltstack | awk NF | awk '{print $0}' | awk '{print $2}')
		if [ ! -z ${HasExist} ];then
			echo "--Information: The crontab task of saltstack has been exist."
		else
			echo "# Saltstack status" >>/tmp/oldcrontab.tmp
			echo '*/5 * * * * sh /usr/local/zabbix/share/zabbix/externalscripts/record.sh' >>/tmp/oldcrontab.tmp
			crontab /tmp/oldcrontab.tmp
		fi
		
	else
		echo "--Information: Crontab need file is not exist."
	fi
}

function restart(){
		setSalt
		if [ $? -eq 0 ];then
			echo "--Information: Set saltstack sucessfully."
		else
			echo "--Information: Set saltstack failure."
		fi
		setCrontab
		if [ $? -eq 0 ];then
			echo "--Information: Crontab of saltstack set sucessfully."
		else
			echo "--Information: Crontab of saltstack set failure."
			exit 127
		fi
		if [ -f $zInit ];then
			$zInit restart
			if [ $? -eq 0 ];then
				echo "--Information: zabbix restart sucessfully."
				echo "--Information: check saltstack monitor of zabbix set sucessfully."
			else
				echo "--Information: zabbix restart failure."
				sleep 3
				echo "--Information: please check script environment or check you zabbix environment."
			fi
		else
			echo "--Information: zabbix agent start failure."
			exit 1
		fi

}
restart
