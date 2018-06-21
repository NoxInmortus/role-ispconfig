#!/bin/bash
# Check number of security update

# Check if aptitude is installed
if [ ! $(/usr/bin/which aptitude) ]; then
        echo "WARN: aptitude not installed"
        exit 1
else
        aptitude=$(which aptitude)
fi

# Check if file /etc/apt/sources.list.d/security.list exist
if [ ! -f /etc/apt/sources.list.d/security.list ]; then
        echo "WARN: /etc/apt/sources.list.d/security.list not found"
        exit 1
fi

if [ ! -z $2 ];then
        echo "WARN: Usage $0 ALL|<paquet>"
        exit 1
fi

if [ -z $1 ]; then
        echo "WARN: Usage $0 ALL|<paquet>"
        exit 1
elif [ $1 == "ALL" ]; then
        package=""
else
        package="$1"
fi

# Count nb security update
nb_update=$($aptitude -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/security.list -o Dir::Etc::sourceparts=/etc/apt/sources.list.d/security.list search "~U$package" | wc -l)

echo $nb_update
