#!/bin/bash 
# Check presence pwhole_etc du jour

DIR_WHOLE="/var/backups"
if [ $(date +%H ) -gt 6 ] ; then
	DATE=$(date +%Y.%m.%d)
else
	DATE=$(date +%Y.%m.%d --date "yesterday")
fi
PWHOLE="pwhole_etc-$DATE.tar.gz"

if [ -f $DIR_WHOLE/$PWHOLE ];then
	echo 1
	exit 0
else
	echo 0
	exit 0
fi
