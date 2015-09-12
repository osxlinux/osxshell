#!/bin/bash
x=$(cat /etc/issue | grep -v "^$" |  awk 'NR==1{if($1=="Ubuntu")
		{print $1,$2,"'"$(uname -m)"'"}
	else if ($3=="SUSE")
		{print $3,$7,"'"$(uname -m)"'"}
	else if ($1="CentOS")
		{print $1,$3,"'"$(uname -m)"'"}}'
)
echo $x
