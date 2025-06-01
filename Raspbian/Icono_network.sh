#!/usr/bin/bash
Icono_Conexion(){
	yad --notification \
  --image="$1" \
  --text="WIFI Conectado" \
  --command="" \
  --no-middle

	}
	

Stcontrol1="asdf123"
Stcontrol2="asdf123"
while true ; do
	Status1=$(nmcli device | grep " conectado ")
	Status2=$(nmcli device | grep " conectando ")
	Interface=$(echo $Status1 | awk '{print $2}')
	if [ "$Stcontrol1" != "$Status1" ] || [ "$Stcontrol2" != "$Status2" ] ; then
		pid=$(ps -ax | grep -v grep | grep 'yad --notification' | awk '{print $1}')
		[ ! -z $pid ] && kill -9 $pid
		echo $pid
		
		if [ -z "$Status1" ] ; then
			if [ -z "$Status2" ] ; then
				Icono_Conexion network-offline &
			else
				Icono_Conexion "/usr/share/icons/Adwaita/16x16/status/network-wired-acquiring-symbolic.symbolic.png" &
			fi
			
		else
			if [ "$Interface" = "wifi" ] ; then	
				Icono_Conexion network-wireless-connected-75 &
			elif [ "$Interface" = "eth0" ] ; then
				Icono_Conexion network-transmit-receive &	
			fi
		fi
		Stcontrol1=$Status1
		Stcontrol2=$Status2
	fi
	
	sleep 1
done	
	
