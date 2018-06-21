#/bin/sh

facter 2> /dev/null  | grep "^manufacturer" | awk '{ print $3 }'
