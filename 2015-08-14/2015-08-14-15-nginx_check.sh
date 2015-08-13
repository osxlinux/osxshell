#!/bin/sh
#by:xdd
#Email:osx1260@163.com
#Check nginx status and restart test server
# if nginx restart failed the nginx server will switch other server of standby
#Date 2015-08-12 01:28
Port=8080
Pro_nginx=/etc/init.d/nginx
Datetime=$(date +%Y-%m-%d-%H:%M:%S)
Pro_keepalive=/etc/init.d/keepalived
Switch_Log=/var/log/nginx_keepalived.log

Re_value=$(lsof -i:${Port} | egrep "http|LISTEN" | awk 'NR==1{printf("%s\n",$1)}')
echo $Re_values
if [[ $Re_value != 'nginx' ]];then
    $Pro_nginx start
    sleep 3
    Re_values=$(lsof -i:${Port} | egrep "http|LISTEN" | awk 'NR==1{printf("%s\n",$1)}')
    if [[ $Re_values != 'nginx' ]];then
        echo "Server restart failed ! via  keepalive "
        echo "$Datetime Record keepalive switch standby server" >>$Switch_Log
        $Pro_keepalive stop
    else
		echo "Nginx server restart successfull"        
    fi
else
   echo -e "$Datetime Nginx Server is  normal" >> $Switch_Log
fi


