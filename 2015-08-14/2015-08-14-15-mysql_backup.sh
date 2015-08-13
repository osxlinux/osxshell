#!/bin/bash
#by:xingdd
#Email:osx1260@163.com
#Build Date: 2015-08-12 22:10

User_Check=$(id -u)
Date_Format=$(date +%Y-%m-%d-%H-%M)
LOG_Dir=$(pwd)/log/BakInfo.log
MySQL_run=/usr/local/mysql/bin/mysql
MYSQLadmin_run=/usr/local/mysql/bin/mysqladmin
Back_order=/usr/local/percona-xtrabackup/bin/innobackupex 

#clear Last backup log
>$LOG_Dir

function check_mysql_version(){
	if [ -d /usr/local/mysql ];then
		MySQL_Ver=$($MySQL_run  -V | awk '{print $5}' | awk -F'-' '{print $1}')
		echo "MySQL Version: $MySQL_Ver"
	else
		echo "You are not installed Mysql Server."
    	exit 1
	fi
	}

function user_check(){
	if [  ${User_Check} -eq 0 ];then
    	echo "Start check env ...."
	else
		echo "##You mast run this script as root user "
    	exit 1
	fi
	}

function login_pass_set(){
	stty -echo 
	read -p "Please enter your mysql password for root:" PW
	echo ""
    echo "Start backup please waitting ..............."
	stty echo
	}


function check_mysql_login(){
	if [[ $($MYSQLadmin_run -uroot -p${PW} ping | wc -l) -eq 1 ]];then
		echo "Access login the mysql server..."
	else
		echo "Login filed mysql"
		exit 1
	fi
	}

function check_back_result(){
	if [ -f $LOG_Dir ];then
		Resu_values=$(cat $LOG_Dir | egrep "Error|error|Failed")
        Resu_remeber=$(cat $(pwd)/log/BakInfo.log  | grep position | awk -F',' '{print $1,$2}' | awk -F':' '{print $2$3}')
		if [[ -z $Resu_values ]];then
			echo "Hot backup is successful ......"
			echo  -e "$Date_Format\t$Resu_remeber" >> $(pwd)/log/Record.log
            echo "#####when you finished this script Please check the last Record.log about mysql binlog and positionID"
		else
			echo "Hot backup is failed ......"
			echo "Please check your environment ......"
            exit 0
		fi
    else
		echo "You are not run this script or this script is not builed logfile !!!"
	fi
	}

check_mysql_version
if [ -d /usr/local/percona-xtrabackup ];then
    user_check
	login_pass_set
	$Back_order --defaults-file=/etc/my.cnf --user=root --password=${PW} --no-timestamp /tmp/$Date_Format 2>&1 | tee -a $LOG_Dir >/dev/null
	check_back_result
    tar -jcvf /tmp/$Date_Format.tar.bz2 /tmp/$Date_Format >/dev/null 2>&1
    echo "Hotback dir is /tmp/$Date_Format"
    echo "Hotback file of tar package is  /tmp/$Date_Format.tar.bz2"
else
    user_check
	source $(pwd)/install_xtr.sh
    login_pass_set
	$Back_order --defaults-file=/etc/my.cnf --user=root --password=${PW} --no-timestamp /tmp/$Date_Format 2>&1 | tee -a $LOG_Dir >/dev/null
    check_back_result
    tar -jcvf /tmp/$Date_Format.tar.bz2 /tmp/$Date_Format >/dev/null 2>&1
    echo "Hotback dir is /tmp/$Date_Format"
    echo "Hotback file of tar package is  /tmp/$Date_Format.tar.bz2"
fi

##################################################################################################################################################
#!/bin/bash
localdir=$(pwd)
tar -zxf  $localdir/percona-xtrabackup-2.2.5-Linux-x86_64.tar.gz
if [ -d /usr/local/product  ];then
	cp -r  $localdir/percona-xtrabackup-2.2.5-Linux-x86_64 /usr/local/product 
	ln -s /usr/local/product/percona-xtrabackup-2.2.5-Linux-x86_64 /usr/local/percona-xtrabackup
	exit 0
else
	cp -r $localdir/percona-xtrabackup-2.2.5-Linux-x86_64 /usr/local/percona-xtrabackup
fi

