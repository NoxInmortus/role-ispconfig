#!/bin/bash

REDISCLI=$(which redis-cli)

usage()
{
cat << EOF
usage: $0 options

OPTIONS:
   -h      Show this message
   -s      Server address
   -i      Info
   -c	   Config Get
EOF
}

TEST=
SERVER=
PASSWD=
VERBOSE=
while getopts “hs:i:c:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         s)
             SERVER=$OPTARG
             ;;
         i)
             INFO=$OPTARG
             ;;
	 c)
	     CONFIG=$OPTARG
	     ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $SERVER ]] || [[ -z $INFO ]] && [[ -z $CONFIG ]]
then
     usage
     exit 1
fi

if [[ -z $CONFIG ]]; then
	$REDISCLI -h $SERVER info | grep ${INFO}: | cut -d":" -f2
else
	$REDISCLI -h $SERVER config get $CONFIG | tail -n +2
fi
