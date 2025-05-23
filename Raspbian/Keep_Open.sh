#! /bin/bash
cd "$(dirname "$0")"

while true ; do
	if [ -z "$(ps -ax | grep -v grep | grep LotobetClientExe)" ] ; then
		sleep 1
		if [ -z "$(ps -ax | grep -v grep | grep LotobetClientExe)" ] ; then
			/usr/bin/java -jar /home/ventas/lotobet/LotobetClientExe.jar &
			sleep 5
		fi
	fi
	
	if [ -z "$(ps -ax | grep -v grep | grep calculator)" ] ; then
		sleep 1
		if [ -z "$(ps -ax | grep -v grep | grep calculator)" ] ; then
			gnome-calculator &
			sleep 5
		fi
	fi
	
	sleep 1
done

