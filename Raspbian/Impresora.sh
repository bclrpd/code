#! /bin/bash
cd "$(dirname "$0")" 				
lpadmin -p Impresora -v "serial:/dev/ttyUSB0" 	#Esta linea desaparece con la primera ejecucion

sed -i '3,4d' ./Impresora.sh 			#Esta linea desaparece con la primera ejecucion
chmod 777 /dev/vchiq

#-----Agregar Vendor de la Impresora a /usr/share/cups/usb/org.cups.usb-quirks
Add_Vendor_Printer () {
	Vendor="0x$1"
	YY=$(cat /usr/share/cups/usb/org.cups.usb-quirks | grep $Vendor)
	if [ -z "$YY" ] ; then
		echo "$Vendor unidir" >> /usr/share/cups/usb/org.cups.usb-quirks
	fi
}
Add_Vendor_Printer "4b43"
#---------------------------------------------------------------
while true ; do

	URI=$(lpstat -s |grep "para Impresora" | awk '{print $4}')
	NEWURI=$(lpinfo -v |grep "usb" | awk '{print $2}')
	NEWURI2=$(lpinfo -v | grep "serial:/dev/ttyUSB0" | awk '{print $2}')
	echo $URI
	echo $NEWURI
	echo $NEWURI2

	if [ ! -z $NEWURI ] ; then
		if [ $NEWURI != $URI ] ; then
			lpadmin -x Impresora
			sleep 1
			lpadmin -p Impresora -E -v $NEWURI
			sleep 1
			lpadmin -d Impresora
			echo "Actualizada"
		fi
		break
	elif [ ! -z $NEWURI2 ] ; then
	
		if [ $NEWURI2 != $URI ] ; then
			lpadmin -x Impresora
			sleep 1
			lpadmin -p Impresora -E -v $NEWURI2
			sleep 1
			lpadmin -d Impresora
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

#------------------------------------------
if [ ! -z $NEWURI2 ] ; then
	while true ; do
		A=$(lpstat Impresora | grep "Impresora" | awk '{print $1}')
		if [ ! -z "$A" ] ; then
			Printer=$(lpinfo -v | grep "serial:/dev/ttyUSB0")
			if [ ! -z "$Printer" ] ; then
				sleep 3
				A2=(${A})
				for i in "${A2[@]}" ; do
					JOB=${i##*-}
					A3=$(lpstat Impresora | grep "Impresora-$JOB" -w | awk '{print $1}')
					if [ ! -z "$A3" ] ; then
						lp -i $JOB -H resume
						sleep 1
					fi
				done
			else
				sleep 1
			fi
		else
			sleep 5
		fi
	done
fi
