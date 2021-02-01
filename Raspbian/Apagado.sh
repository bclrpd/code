#! /bin/bash

while true ; do
sleep 10
TIME=$(cat </dev/tcp/time.nist.gov/13)
if [ $? -eq 0 ] ; then
	Array=($TIME)
	Hora=$(date --date "${Array[2]} today - 240 minutes" +%H%M)	
	if [ $Hora -eq $(date +%H%M) ] ; then
		if [ $(date +%w) -ne 0 ] && [ $(date +%H%M) -lt 1505 ] ; then
			shutdown 15:10
			break
		else
			break
		fi	
	fi
fi
sleep 10
done
