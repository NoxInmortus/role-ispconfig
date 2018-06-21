#!/bin/bash
# Check if host if blocked by mysql

MYSQLADMIN=$(which mysqladmin)

STATUS=$(mysqladmin -h $3 -u$1 -p$2 status 2>&1 | tail -n 1)

if [[ $STATUS =~ "Uptime: " ]]; then
        echo "OK - "
else    
        echo "CRITICAL - $STATUS"
fi
