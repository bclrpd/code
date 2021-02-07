#! /bin/sh
MAC=$(nmcli d show eth0 | grep GENERAL.HWADDR: | awk '{print $2}')
CLONEMAC=$(nmcli c show 'Wired connection 1' | grep cloned-mac-address:| awk '{print $2}')
if [ ! $MAC = $CLONEMAC ] ; then	
	sudo nmcli c mod 'Wired connection 1' 802-3-ethernet.cloned-mac-address $MAC
	#sudo nmcli c mod 'Wi-Fi connection 1' 802-11-wireless.cloned-mac-address $MAC
	nmcli n off
	sleep 1
	nmcli n on
fi

while true ; do
if [ $(nmcli d |grep "connected" -w | awk 'NR==1 {print $2}') ] ; then

	if [ $(nmcli d |grep "connected" -w | awk 'NR==1 {print $1}') != "eth0" ] && [ $(nmcli d |grep "connected" -w | awk 'NR==1 {print $1}') != "eth1" ] && [ $(nmcli d |grep "connected" -w | awk 'NR==1 {print $1}') != "usb0" ] ; then
		sudo ifconfig eth0 1.1.1.1 netmask 255.255.255.0 up	
		break
	fi
else
	sleep 1
fi
done

#-------------
sleep 10
sudo apt-get purge --auto-remove mutt -y
sleep 2
sudo apt-get purge --auto-remove xmlstarlet -y
sleep 2

exit 0

