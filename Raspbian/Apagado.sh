#! /bin/bash
while true ; do
	sleep 10
	until ping -nq -c3 8.8.8.8; do
		sleep 1
	done
	
	sleep 300
	
	if [ $(date +%w) -ne 0 ] ; then
		shutdown 15:10
		break
	else
		break
	fi	
done
