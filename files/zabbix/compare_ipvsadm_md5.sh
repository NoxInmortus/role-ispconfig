#!/bin/bash
# Script to compare ipvsadm md5

usage()
{
cat << EOF
        usage: $0 <server1> <server2>
EOF
}

if [ -z $1 ] || [ -z $2 ] || [ $# -ne 2 ]; then
        usage
        exit 1
fi

SERVER1_MD5=$(/usr/bin/zabbix_get -s $1 -k ipvsadm.md5)
SERVER2_MD5=$(/usr/bin/zabbix_get -s $2 -k ipvsadm.md5)

if [ $SERVER1_MD5 != $SERVER2_MD5 ]; then
        echo "1"
else   
        echo "0"
fi
