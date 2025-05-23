#!/bin/sh
cd "$(dirname "$0")"
numlockx on

Reinicar_Modem(){

if ping 192.168.1.1 -i 0.5 -w 5 ; then
	python3 /home/ventas/.Auto/Reboot.py Alcatel &
	(
		for i in {1..50} ; do
		echo "#.		ERROR DE CONEXION 		.\n" \
		"             	REINICIANDO MODEM " 
		echo "$(( i * 2))"
		sleep 1
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

	systemctl reboot -i
	
elif ping 192.168.8.1 -i 0.5 -w 5 ; then
	python3 /home/ventas/.Auto/Reboot.py Huawei &
	(
		for i in {1..50} ; do
		echo "#.		ERROR DE CONEXION 		.\n" \
		"             	REINICIANDO MODEM " 
		echo "$(( i * 2))"
		sleep 1
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

	systemctl reboot -i
else
	zenity --error --text="NO HAY CONEXION A INTERNET\nLLAMA A TU SUPERVISOR" \
	--width="300" --height="100" --timeout=60
	systemctl reboot -i
fi
}

Conectar_Modem(){
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
				sleep 7
			fi
		fi
	fi
}

Conectar_Modem
(
. Estado.ini
echo "# CONSORCIO DE BANCAS LA RAPIDA" ; sleep 1
for i in {0..4} ; do
	echo "25"
	echo "# CONECTANDO" ;sleep 1
	ping 8.8.8.8 -i 0.5 -w 5 -q
	if [ $? -eq 0 ] ;then
		bash UpdateChek.sh &
  		(gnome-calculator)&
		#(/usr/bin/java -jar /home/ventas/lotobet/Lotobet.jar)&
		(/usr/bin/java -jar /home/ventas/lotobet/LotobetClientExe.jar)&
		echo "ESTADO=Conectado" > Estado.ini
		echo "REINICIO=0" >> Estado.ini	
		echo "75" ; sleep 1
		echo "# CONEXION EXITOSA" ; sleep 1
		echo "90"
		echo "# FINALIZANDO" ; sleep 1	
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
		Conectar_Modem
		echo "ESTADO=Desconectado" > Estado.ini
		echo "REINICIO="$((${REINICIO} + 1)) >> Estado.ini
		echo "#.		ERROR DE CONEXION 		.\n" \
		"              NUEVO INTENTO EN 5 S " ;sleep 1
		echo "#.		ERROR DE CONEXION 		.\n" \
		"              NUEVO INTENTO EN 4 S " ;sleep 1
		echo "#.		ERROR DE CONEXION 		.\n" \
		"              NUEVO INTENTO EN 3 S " ;sleep 1
		echo "#.		ERROR DE CONEXION 		.\n" \
		"              NUEVO INTENTO EN 2 S " ;sleep 1
		echo "#.		ERROR DE CONEXION 		.\n" \
		"              NUEVO INTENTO EN 1 S " ;sleep 1

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
				zenity --info --text="Se Perdio La Conexion a Internet\nLa Computadora Se Reiniciara En 10 Segundos" \
				--width="400" --height="100" --timeout=10
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
				zenity --error --text="MODEM NO DETECTADO\nLA COMPUTADORA SE REINICIARA" \
				 --width="300" --height="100" --timeout=10
				reboot
				break
			fi
		fi
	done
elif [ ${REINICIO} -gt 2 ] ; then
	if [ $(nmcli n c) = "full" ] ; then
		if ((${REINICIO} % 3 == 0 )); then
			Reinicar_Modem
		else
			zenity --error --text="NO HAY CONEXION A INTERNET\nLLAMA A TU SUPERVISOR" \
			 --width="300" --height="100" --timeout=60
			systemctl reboot -i
		fi
		
	else
		zenity --error --text="MODEM NO DETECTADO\nLLAMA A TU SUPERVISOR" \
		 --width="300" --height="100" --timeout=60
		 systemctl reboot -i
	fi
elif [ $(nmcli n c) = "full" ] ; then
	zenity --error --text="NO HAY CONEXION A INTERNET\nLA COMPUTADORA SE REINICIARA" \
	 --width="300" --height="100" --timeout=10
	systemctl reboot -i
else 
	zenity --error --text="MODEM NO DETECTADO\nLA COMPUTADORA SE REINICIARA" \
	--width="300" --height="100" --timeout=10
	systemctl reboot -i 
fi
