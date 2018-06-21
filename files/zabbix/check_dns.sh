#!/bin/bash
# Script de verification dispo serveur DNS
# JOT

if [ -z $8 ]; then
        echo "Usage $0 [-S] <Server to check> [-D] <domain to query> [-Ti] <timeout in s> [-Tr] <Number of trie(s)>" ; exit 1 ;
fi

# Check args
while true ; do
        if [ ! -z $1 ] ; then
        case "$1" in
                -S) SERV=$2 ; shift 2;;
                -D) DOM=$2 ; shift 2;;
                -Ti) TIME=$2 ; shift 2;;
                -Tr) TRIE=$2 ; shift 2;;
                *|-h|--help) echo "Usage $0 [-S] <Server to check> [-D] <domain to query> [-Ti] <timeout in s> [-Tr] <Number of trie(s)>" ; exit 1 ;;
        esac ; else
                break ;
        fi
done

# Variables
TMP_PATH=/tmp/
tmp_file=$TMP_PATH/$2_${RANDOM}.tmp

RESULT_DNS=$(dig +nocmd +time=$TIME +tries=$TRIE A $DOM @$SERV +nocomments +noauthority +noquestion > $tmp_file; echo $?)

if [ $RESULT_DNS -eq 0 ]; then
        echo "OK - $(cat $tmp_file)"
else   
        echo "ERROR - $(cat $tmp_file)"
fi

# Purge file
if [ -f $tmp_file ]; then
        rm $tmp_file
fi
