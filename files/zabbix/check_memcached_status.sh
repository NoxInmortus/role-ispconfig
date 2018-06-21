#/bin/bash

######################################################
## PLugins for monitoring memory usage by Memcached ##
## Author : Jeremy Muriel (jeremy@jeremm.fr         ##
## Adapted for zabbix by : Jonathan THIBERVILLE	    ##
######################################################
# Test bin

if [ ! -x /bin/nc ] ; then
        echo "please install netcat"
        exit 3
fi

if [ ! -x /bin/grep ] ; then
        echo "please install grep"
        exit 3
fi

if [ ! -x /usr/bin/cut ] ; then
        echo "please install cut"
        exit 3
fi

# Variables

ip='localhost'
port='11211'
type='mem'

while true ; do
        if [ ! -z $1 ] ; then
        case "$1" in
                -H|--Hostname) ip=$2 ; shift 2;;
                -p|--port) port=$2 ; shift 2;;
		-t|--type) type=$2 ; shift 2;;
                *|-h|--help) echo "Usage $0 [-H|--Hostname] [-p|--port] [-t|--type(mem|conn)]" ; exit 3 ;;
        esac ; else
                break ;
        fi
done

# version

version=$( echo -e "stats\nquit" | /bin/nc $ip $port | /bin/grep "STAT version" | /usr/bin/cut -d' ' -f3 | sed 's/\r//g')
if [ -z $version  ] ; then
        echo "-1" ; exit 0
fi

version1=$(echo $version | /usr/bin/cut -d'.' -f1)
version2=$(echo $version | /usr/bin/cut -d'.' -f2)
version=$(echo $version1'.'$version2)

# check type
if [ $type != "mem" -a $type != "conn" ];then
	echo "-1"; exit 0
fi

# get status

use=$( echo -e "stats\nquit" | /bin/nc $ip $port | /bin/grep "STAT bytes " | /usr/bin/cut -d' ' -f3 | sed 's/\r//g')
if [ -z $use  ] ; then
        echo "-1" ; exit 0
fi

total=$( echo -e "stats\nquit" | /bin/nc $ip $port | /bin/grep "STAT limit_maxbytes" | /usr/bin/cut -d' ' -f3 | sed 's/\r//g')

if [ -z $total ] ; then
        echo "-1" ; exit 0
fi

if [ $version != "1.2" -a $version != "1.1" ] ; then

        cuse=$( echo -e "stats\nquit" |  /bin/nc $ip $port | /bin/grep "STAT curr_connections" | /usr/bin/cut -d' ' -f3 | sed 's/\r//g')
        if [ -z $cuse  ] ; then
                echo "-1" ; exit 0
        fi

        ctotal=$( echo -e "stats settings\nquit" |  /bin/nc $ip $port | /bin/grep "STAT maxconns " | /usr/bin/cut -d' ' -f3 | sed 's/\r//g')
        if [ -z $ctotal ] ; then
                echo "-1" ; exit 0
        fi
fi

# calcul Status
pourc=$(( $use * 100 / $total ))
if [ $version != "1.2" -a $version != "1.1" ] ; then
        cpourc=$(( $cuse * 100 / $ctotal ))
fi

if [ $version != "1.2" -a $version != "1.1" ] ; then

	if [ $type == "mem"  ];then
	                echo "$pourc" ; exit 0
	fi
	if [ $type == "conn"  ];then
          	      echo "$cpourc" ; exit 0
	fi
else
        if [ $type == "conn"  ];then
		echo "-2"
	else
	                echo "$pourc" ; exit 0
	fi
fi

exit 3
