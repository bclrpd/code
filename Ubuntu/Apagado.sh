#! /bin/bash

while true ; do
sleep 10

until ping -nq -c3 8.8.8.8; do
	sleep 1
done
while [ -z "$TIME" ]; do
	TIME="$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
	sleep 1
done

Hora=$(date -d "$TIME" +%H%M)
if [ $Hora -eq $(date +%H%M) ] ; then
		if [ $(date +%w) -ne 0 ] && [ $(date +%H%M) -lt 1505 ] ; then
			shutdown 15:10
			break
		else
			break
		fi	
	fi
done
