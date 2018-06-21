#!/bin/bash
# Check postgres replication status

usage()
{
cat << EOF
usage: $0 options

OPTIONS:
   -h      Show this message
   -s      Slave address
   -e	   State of the slave
   -l      max lag
EOF
}

while getopts "hs:e:l:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         s)
	     if [[ $OPTARG =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
             	SLAVE="'$OPTARG'"
	     else
        	echo "not a valid IP"
		usage
        	exit 1
	     fi
             ;;
	 e)
	     STATE=$OPTARG
	     ;;
         l)
             LAG=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $SLAVE ]] || [[ -z $LAG ]] || [[ -z $STATE ]]
then
     usage
     exit 1
fi

CUR_STATE=$(su - postgres -c "psql -A -t -c\"select state from pg_stat_replication where client_addr=${SLAVE}\"")

if [[ $CUR_STATE != $STATE ]]; then
	echo "CRITICAL: replication not working"
	exit 0
fi

CUR_LAG=$(su - postgres -c "psql -A -t -c\"SELECT pg_xlog_location_diff(pg_stat_replication.sent_location, pg_stat_replication.replay_location) FROM pg_stat_replication where client_addr=${SLAVE}\"")

if [[ $CUR_LAG -gt $LAG ]]; then
	echo "CRITICAL: replication delay $CUR_LAG > $LAG"
	exit 0
else
	echo "OK: replication delay $CUR_LAG < $LAG"
	exit 0
fi
