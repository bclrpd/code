#! /bin/bash
			#se ejecuta desde Impresora.sh
while true ; do
	until ping -nq -c3 8.8.8.8; do
		sleep 1
	done
	TIME=""
	while [ -z "$TIME" ]; do
		sleep 5
		TIME="$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
	done
	HoraInternet=$(date -d "$TIME" +"%H%M")
	HoraLocal=$(date +"%H%M")
	if [ $HoraInternet -ne $HoraLocal ] ; then
		TIME2=$(date -d "$TIME" +"%Y-%m-%d %H:%M:%S")
  		timedatectl set-ntp false
		sleep 1
		timedatectl set-time "$TIME2"
  		sleep 1
		timedatectl set-ntp true
	fi
	sleep 300
done
