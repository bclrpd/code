#! /bin/bash


while true ; do

URI=$(lpstat -s |grep "para Impresora" | awk '{print $4}')
NEWURI=$(lpinfo -v |grep "usb" | awk '{print $2}')
echo $URI
echo $NEWURI

if [ ! -z $NEWURI ] ; then

	if [ $NEWURI != $URI ] ; then
		lpadmin -p Impresora -v $NEWURI
		echo "Actualizada"
	fi
	break
fi
sleep 2
done

#--------Sincronizar Hora-------------
until ping -nq -c3 8.8.8.8; do
	sleep 1
done
sleep 5
while [ -z "$TIME" ]; do
	TIME="$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
	sleep 1
done

if [ "$(timedatectl | grep "System clock synchronized:" | awk '{print $4}')" != "yes" ] ; then
	timedatectl set-ntp false
	sleep 1
	TIME2=$(date -d "$TIME" +"%Y-%m-%d %H:%M:%S")
	timedatectl set-time "$TIME2"
	sleep 1
	timedatectl set-ntp true
	echo "hecho"
fi
