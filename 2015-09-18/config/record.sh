#!/bin/bash
getPrPid=$(ps -ef | grep salt | egrep -v "($0|grep)" | awk '{print $2}')
pidPath=/tmp/salt_minitor.tmp
dateFomat=$(date +%Y-%m-%d\ %H:%M:%S)
echo "$dateFomat $getPrPid" >$pidPath 2>&1
