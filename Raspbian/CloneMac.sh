#! /bin/sh
MAC=$(nmcli d show eth0 | grep GENERAL.HWADDR: | awk '{print $2}')
CLONEMAC=$(nmcli c show 'Conexión cableada 1' | grep cloned-mac-address:| awk '{print $2}')
if [ ! $MAC = $CLONEMAC ] ; then	
	sudo nmcli c mod 'Conexión cableada 1' 802-3-ethernet.cloned-mac-address $MAC
	nmcli n off
	sleep 1
	nmcli n on
fi

nmcli c up "Conexión cableada 1"
sleep 1

while true ; do
CON1=$(nmcli d |grep "conectado" -w | awk 'NR==1 {print $1}')
CON2=$(nmcli d |grep "conectado" -w | awk 'NR==2 {print $1}')

if [ $CON1 ] ; then

	if [ "$CON1" != "eth0" ] && [ "$CON1" != "eth1" ] && [ "$CON1" != "usb0" ] ; then
		if [ "$CON2" != "eth0" ] && [ "$CON2" != "eth1" ] && [ "$CON2" != "usb0" ] ; then		
			sudo ifconfig eth0 1.1.1.1 netmask 255.255.255.0 up	
		fi		
	fi
	break
else
	sleep 1
fi
done

exit 0

