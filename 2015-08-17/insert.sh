#!/bin/bash
set -x
read -p "Please Enter an address of china city name:" ADD

read -p "Please Enter a initial value for city linke status:Defalut 50:" AVR

if [ -z $AVR ];then
	AVR=50
else
	continue
fi
mysql -uroot -p"password" -D"mydata" -e "insert into mapdata(name,value) values(\"${ADD}\",$AVR);"
