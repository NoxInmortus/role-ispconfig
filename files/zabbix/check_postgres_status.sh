#!/bin/bash
# Check postgres status

if [ -z $1 ]; then
	echo "Usage $0 state|count"
        exit 0
fi

if [ $1 == "state" ];then
	retour=$(su - postgres -c 'psql -t -c"select count(*) from pg_stat_activity " 2>&1 ' )
	status=$(echo $?)
	if [ $status == 0 ];then
		echo "OK - $retour"
		exit 0
	else
		echo "CRITICAL - $retour"
                exit 0
	fi
	
elif [ $1 == "count" ];then
	count=$(su - postgres -c 'psql -t -c"select count(*) from pg_stat_activity" 2>&1')
	echo $count
	exit 0
else
	echo "Usage $0 state|count"
	exit 0
fi
