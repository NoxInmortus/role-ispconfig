#!/bin/bash

if [ -z $1 ];then
	echo "ERROR - manque argument"
	exit 1
fi

wget -t $2 -T $3 -S -O /dev/null --no-check-certificate --max-redirect=0 $1 2>&1 | grep "HTTP/1"
