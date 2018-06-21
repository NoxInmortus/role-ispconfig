#!/bin/bash
# Script de check metier

if [ ! -x /usr/bin/curl ] ; then
        echo "-2"; exit 0
fi

# Variables

host='localhost'
prot='http'
ip='localhost'
motif='AWH'

while true ; do
        if [ ! -z $1 ] ; then
        case "$1" in
                -H|--host) host=$2 ; shift 2;;
                -p|--prot) prot=$2 ; shift 2;;
                -i|--ip) ip=$2 ; shift 2;;
                -m|--motif) motif=$2 ; shift 2;;
                -c|--chemin) chemin=$2 ; shift 2;;
                *|-h|--help) echo "Usage $0 [-H|--host] [-p|--prot] <http|https> [-i|--ip] [-m|--motif] [-c|--chemin]" ; exit 3 ;;
        esac ; else
                break ;
        fi
done

# Check

if [ $prot != "http" -a $prot != "https" ];then
        echo "-1"; exit 0
fi

# Curl

if [ $prot == "http" ]; then
	pattern=$(curl -k -s --header "Host: $host" "http://$ip/$chemin" | grep -o "$motif" | wc -l)
else
	pattern=$(curl -k -s --header "Host: $host" "https://$ip/$chemin" | grep -o "$motif" | wc -l)
fi

echo $pattern
