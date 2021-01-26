#!/bin/sh
cd "$(dirname "$0")"
numlockx on

if [ -z $(nmcli d |grep "conectado" -w | awk 'NR==1 {print $2}') ] ; then	 #Revisa si no hay conexion
	if [ $(nmcli n) = "disabled" ] ;then #Revisa si Networking esta desactivado, si es asi lo activa 
		nmcli n on
		sleep 5
	fi
	if [ -z $(nmcli d |grep "conectado" -w | awk '{print $2}') ] ;then #Revisa si aun no hay conexion
		if [ $(nmcli r wifi) = "disabled" ] ; then #Revisa si WIFI esta desactivado, si es asi lo activa 
			nmcli r wifi on
			sleep 5
			if [ -z $(nmcli d |grep "conectado" -w | awk '{print $2}') ] ; then #Revisa si aun no hay conexion
				nmcli c up "Conexión inalámbrica 1" &
			fi
		else
			nmcli c up "Conexión inalámbrica 1" &
		fi
	fi
fi

(
. Estado.ini
echo "# CONSORCIO DE BANCAS LA RAPIDA" ; sleep 1
for i in {0..4} ; do
	echo "25"
	echo "# CONECTANDO" ;sleep 1
	ping 8.8.8.8 -i 0.5 -w 5
	if [ $? -eq 0 ] ;then
		(/usr/bin/java -jar /home/ventas/lotobet/Lotobet.jar)&
		echo "ESTADO=Conectado" > Estado.ini
		echo "REINICIO=0" >> Estado.ini	
		echo "75" ; sleep 1
		echo "# CONEXION EXITOSA" ; sleep 1
		echo "90"
		echo "# FINALIZANDO" ; sleep 1	
		sleep 7
		(gnome-calculator)&
		sleep 2
		if [ "$(nmcli d |grep "conectado" -w | awk 'NR==1 {print $2}')" == "wifi" ] || [ "$(nmcli d |grep "conectado" -w | awk 'NR==2 {print $2}')" == "wifi" ] ;then
			if [ -z $(ifconfig |grep "inet 1.1.1.1  netmask 255.255.255.0  broadcast 1.1.1.255" | awk 'NR==1 {print $2}') ] ; then
				nmcli r wifi off
			fi
		else
			nmcli r wifi off
		fi	
		echo "100"
		break
		
	else
		if [ $(nmcli n c) = "none" ] ; then
			nmcli radio wwan on
			sleep 10
		fi
		echo "ESTADO=Desconectado" > Estado.ini
		echo "REINICIO="$((${REINICIO} + 1)) >> Estado.ini
		echo "# ERROR DE CONEXCION \n" \
		"NUEVO INTENTO EN 5 S" ;sleep 1
		echo "# ERROR DE CONEXCION \n" \
		"NUEVO INTENTO EN 4 S" ;sleep 1
		echo "# ERROR DE CONEXCION \n" \
		"NUEVO INTENTO EN 3 S" ;sleep 1
		echo "# ERROR DE CONEXCION \n" \
		"NUEVO INTENTO EN 2 S" ;sleep 1
		echo "# ERROR DE CONEXCION \n" \
		"NUEVO INTENTO EN 1 S" ;sleep 1

	fi
done
) | 
zenity --progress \
--title="BANCA LA RAPIDA" \
--text="" \
--width="300" \
--height="100" \
--percentage=0 \
--auto-close \
--auto-kill \
--no-cancel


. Estado.ini
echo ${ESTADO}
if [ ${ESTADO} = "Conectado" ] ;then
	CONTADOR=0
	while true ;do
		ping -s 8 8.8.8.8 -c 10
		if [ $? -eq 0 ] ;then
			CONTADOR=0
			sleep 50
			continue
		elif [ $(nmcli n c) = "full" ] ; then
			if [ $CONTADOR -lt 6 ] ; then
				let CONTADOR++
			else
				echo "ESTADO=Desconectado" > Estado.ini
				echo "REINICIO="$((${REINICIO} + 1)) >> Estado.ini
				zenity --info --text="Se Perdio La Conexion a Internet\n La Computadora Se Reiniciara En 10 Segundos" \
				--width="300" --height="100" --timeout=10
				reboot
				break
			fi
		else
			sleep 10
			if [ $CONTADOR -lt 6 ] ; then
				let CONTADOR++
			else
				echo "ESTADO=Desconectado" > Estado.ini
				echo "REINICIO="$((${REINICIO} + 1)) >> Estado.ini
				zenity --info --text="Modem NO Detectado\n La Computadora Se Reiniciara En 10 Segundos" \
				--width="300" --height="100" --timeout=10
				reboot
				break
			fi
		fi
	done
elif [ $REINICIO -gt 3 ] ; then
	if [ $(nmcli n c) = "full" ] ; then
		zenity --info --text="NO SE PUDO ESTABLECER CONEXION A INTERNET\n LLAMA A TU SUPERVISOR"
	else
		zenity --info --text="MODEM NO DETECTADO\n LLAMA A TU SUPERVISOR"
	fi
elif [ $(nmcli n c) = "full" ] ; then
	zenity --info --text="NO SE PUDO ESTABLECER CONEXION A INTERNET\n LA COMPUTADORA SE REINICIARA" \
	--timeout=10
	reboot
else 
	zenity --info --text="MODEM NO DETECTADO\n LA COMPUTADORA SE REINICIARA" --timeout=10
	reboot 
fi

