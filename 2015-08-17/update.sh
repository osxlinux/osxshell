#!/bin/bash
set -x
MapAdress="北京 上海 成都 天津 杭州 兰州 广州 邢台 贵阳 营口 郑州 乌鲁木齐"
for address in  $MapAdress;do
	ROND=$(echo $(echo $RANDOM) | cut -nb 3,4)
	mysql -uroot -p'password' -D'yourdata' -e "update mapdata set value=$ROND where name=\"${address}\";"
done
