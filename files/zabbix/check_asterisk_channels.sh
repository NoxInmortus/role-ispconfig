#/bin/sh

asterisk -rx " dahdi show channels" | tail -n 15 | awk '{print $2}' | grep -v "hosting-in" | wc -l
