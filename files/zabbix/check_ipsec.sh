#!/bin/bash
IPSEC=$(which ipsec)

usage()
{
cat << EOF
usage: $0 options

OPTIONS:
   -h      Show this message
   -n      Number of tunnel
EOF
}

check_tunnel() {

        eroutes=`$IPSEC whack --status | grep -e "IPsec SA established" | grep -e "newest IPSEC" | wc -l`

        if [[ "$eroutes" -eq "$NBTUNNEL" ]]
        then   
                echo "OK - $NBTUNNEL tunnels up"
                exit 0
        else   
                echo "CRITICAL - $eroutes tunnels up instead of $NBTUNNEL"
                exit 0
        fi
}

while getopts "hn:" OPTION
do
     case $OPTION in
         h) 
             usage
             exit 1
             ;;
         n)
             NBTUNNEL=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

# Check NBTUNNEL
NUMBER='^[0-9]+$'
if ! [[ $NBTUNNEL =~ $NUMBER ]] ; then
   echo "CRITICAL - $NBTUNNEL is not a number" >&2; exit 1
fi

check_tunnel $NBTUNNEL
