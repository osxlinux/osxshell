#!/bin/bash
DIRE=/var/log/sshd
FIL1=/var/log/sshd/sshderr.log
FIL2=/var/log/sshd/sshd.log
SSHDE=$(grep "f_sshderr"  /etc/syslog-ng/syslog-ng.conf | awk 'NR==1{print $1}')
if [ -f /etc/syslog-ng/syslog-ng.conf ];then
        echo "start config then suse ssh"
        if [ -z "$SSHDE" ];then
cat >>/etc/syslog-ng/syslog-ng.conf<<EOF
filter f_sshderr    { match('^sshd\[[0-9]+\]: error:'); };
filter f_sshd       { match('^sshd\[[0-9]+\]:'); };
destination sshderr { file("/var/log/sshd/sshderr.log"); };
log { source(src); filter(f_sshderr); destination(sshderr); flags(final); };
destination sshd { file("/var/log/sshd/sshd.log"); };
log { source(src); filter(f_sshd); destination(sshd); flags(final); };
EOF
        else
                echo "Has config then suse ssh"
        fi
fi
if [ -d "$DIRE" ];then
        if [[ -f "$FIL1" || -f "$FIL2" ]];then
        echo "The sshd logcatalog has exist"
        else
        touch $FIL1
        touch $FIL2
        fi
else
        mkdir -p $DIRE
        touch $FIL1
        touch $FIL2
fi
