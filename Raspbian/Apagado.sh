#! /bin/bash
until ping -nq -c3 8.8.8.8; do
	sleep 1
done
sleep 300

. Current.ini

if [ "${Tipo}" = "B" ] ;then
	while true ; do
	sleep 20	
	if [ $(date +%w) -ne 0 ] && [ $(date +%H%M) -eq 2110 ] ; then
		shutdown -h now
		break
	fi	
	done
else
	while true ; do
	sleep 20	
	if [ $(date +%w) -ne 0 ] && [ $(date +%H%M) -eq 1510 ] ; then
		shutdown -h now
		break
	elif [ $(date +%w) -ne 0 ] && [ $(date +%H%M) -eq 2110 ] ; then
		shutdown -h now
		break
	fi	
	done
fi
