#!/bin/bash

## Variables
BIND="/etc/bind/named.conf.local"
EXCLUDE="/etc/awh/exclude_domain.txt"
GREP=$(which grep)
DIG=$(which dig)
ERR_DOMAIN=""

## Fonctions
usage()
{
cat << EOF
usage: $0 options

OPTIONS:
   -h      Show this message
   -s      Slave DNS slave1,slave2,slave3...
   -v      Verbose
EOF
}

while getopts "hs:v" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         s)
             SLAVE=$(echo $OPTARG | sed 's/,/ /g')
             ;;
         v)
             VERBOSE=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $SLAVE ]]; then
        usage
        exit 1
fi

# Check if config file exist
if [[ ! -f $BIND ]]; then
        echo "CRITICAL - File $BIND Not Found"
        exit 1
fi

for i in $(cat $BIND | $GREP -v "^//" | grep zones | awk '{ print $2 }' | sed 's/"//g'); do

        if [[ -f $EXCLUDE ]]; then

                if [[ $($GREP "^${i}$" $EXCLUDE | wc -m ) -le 1 ]]; then

                        for j in $SLAVE; do

                                SOA_MASTER=$($DIG SOA $i @localhost +short | awk '{ print $3 }')
                                SOA_SLAVE=$($DIG SOA $i @$j +short | awk '{ print $3 }')

                                if [[ $SOA_MASTER != $SOA_SLAVE ]]; then
                                        if [[ $VERBOSE -eq 1 ]]; then
                                                echo "ALARM $i"
                                                echo "SOA MASTER: $SOA_MASTER"
                                                echo "SOA SLAVE $j: $SOA_SLAVE"
                                        fi
                                        ERR_DOMAIN=${ERR_DOMAIN}" $i Slave: $j"
                                fi

                        done

                fi

        else

                for j in $SLAVE; do

                        SOA_MASTER=$($DIG SOA $i @localhost +short | awk '{ print $3 }')
                        SOA_SLAVE=$($DIG SOA $i @$j +short | awk '{ print $3 }')

                        if [[ $SOA_MASTER != $SOA_SLAVE ]]; then
                                if [[ $VERBOSE -eq 1 ]]; then
                                        echo "ALARM $i"
                                        echo "SOA MASTER: $SOA_MASTER"
                                        echo "SOA SLAVE $j: $SOA_SLAVE"
                                fi
                                ERR_DOMAIN=${ERR_DOMAIN}" $i Slave: $j"
                        fi

                done

        fi

done

if [[ ! -z $ERR_DOMAIN ]]; then
        echo "CRITICAL - $ERR_DOMAIN"
else
        echo "OK - No error"
fi
