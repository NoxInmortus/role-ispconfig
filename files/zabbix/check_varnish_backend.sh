#!/bin/bash
# check backend LIST

# Variables

varnishadm='/usr/bin/varnishadm'

backend='empty'
admin='probe'
probe='Healthy'
type='count'

while true ; do
        if [ ! -z $1 ] ; then
        case "$1" in
                -b|--backend) backend=$2 ; shift 2;;
                -a|--admin) admin=$2 ; shift 2;;
                -p|--probe) probe=$2 ; shift 2;;
		-t|--type) type=$2 ; shift 2;;
                *|-h|--help) echo "Usage $0 [-b|--backend] [-a|--admin] [-p|--probe] [-t|--type (count|list)]" ; exit 1 ;;
        esac ; else
                break ;
        fi
done

# Check 

if [ $type == "count" ];then
	if [ $backend == "empty" ];then 
		count=$($varnishadm backend.list | tail -n +2 | grep $admin | grep $probe | wc -l)
		echo $count
		exit 0
	else
		count=$($varnishadm backend.list $backend | tail -n +2 | grep $admin | grep $probe | wc -l)
                echo $count
                exit 0
	fi
elif [ $type == "list" ];then
	if [ $backend == "empty" ];then
		$varnishadm backend.list | tail -n +2 | grep $admin | grep $probe
	        exit 0
	else
		$varnishadm backend.list $backend | tail -n +2 | grep $admin | grep $probe
                exit 0
	fi
else
	echo -1
	exit 1
fi
