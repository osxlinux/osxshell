#!/bin/bash
#auth:osx1260@163.com
#++++++++++++++++++++++++++++++++++++++++++
# Instruction:
# 100 salt restart
# 127 salt restart failure
# 128 salt stop
# 129 salt has been restart
#+++++++++++++++++++++++++++++++++++++++++
dateFomat=$(date +%Y-%m-%d\ %H:%M:%S)
getPrTotal=$(ps -ef | grep salt | egrep -v "($0|grep)" | wc -l)
getPrPid=$(ps -ef | grep salt | egrep -v "($0|grep)" | awk '{print $2}')
saltPath=/etc/init.d/salt-minion
pidPath=/tmp/salt_minitor.tmp

# salt status
function saltStatus(){
	if [ ${getPrTotal} -ge 1 ];then
        # salt runing 
		echo 0
    else
        # salt stop 
		echo 128
    fi
}
# salt restart
function saltRestart(){
	if [ ${getPrTotal} -eq 0 ];then
		$saltPath stop >/dev/null 2>&1
        $saltPath start >/dev/null 2>&1
        if [ $? -eq 0 ];then
            # restart sucessful
			echo 100
        else
            # restart failure
			echo 127
		fi
    else
		# salt is running
		echo 0
	fi
}

# salt pid change
function saltChange(){
	oldPid=$(cat $pidPath | awk '{print $3}')
	if [ ${oldPid} -eq ${getPrPid} ];then
		echo 0
    else
		# salt has restart
		echo 129
	fi
}
case $1 in
	status)
			saltStatus
		;;
	restart)
			saltRestart
		;;
	change)
			saltChange
		;;
	*)
			echo "--Error enter params"
esac
