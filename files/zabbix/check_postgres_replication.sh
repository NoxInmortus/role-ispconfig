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
EOF
}

while getopts "hs:e:" OPTION
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
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $SLAVE ]] || [[ -z $STATE ]]
then
     usage
     exit 1
fi

CUR_STATE=$(su - postgres -c "psql -A -t -c\"select state from pg_stat_replication where client_addr=${SLAVE}\"")

if [[ $CUR_STATE != $STATE ]]; then
	echo "CRITICAL: replication not working. State: $CUR_STATE"
	exit 0
else
	echo "Ok: replication state $CUR_STATE"
fi
