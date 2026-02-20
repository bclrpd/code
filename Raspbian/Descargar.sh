#!/bin/bash
cd "$(dirname "$0")"

until ping -nq -c3 8.8.8.8; do
	sleep 1
done

cambiar_fondo=1
while [ -z "$TIME" ]; do
	echo "TIEMPO=$((ACUMULADO+$(</proc/uptime awk '{printf int ($1)}')))" > Data.ini
	TIME="$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
	sleep 1
done
Hora=$(date -d "$TIME" +%T)
Fecha=$(date -d "$TIME" +%m/%d/%Y)
if [ $(date --date "$Hora" +%H%M) -lt 1400 ]; then
    Z="$(grep "$Fecha"_1 -w < Registro)"
	if [ "$Z" == *"TARDE"* ]; then
        cambiar_fondo=0
    fi
elif [ $(date --date "$Hora" +%H%M) -gt 1700 ]; then
    Z="$(grep "$Fecha"_2 -w < Registro)"
	if [ "$Z" == *"TARDE"* ]; then
        cambiar_fondo=0
    fi
fi

if [ "$(md5sum Wallpaper.jpg | awk 'NR==1 {print $1}')" != "fb62eed0335a711cf5701699783d59b0" ]; then
	wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Wallpaper.jpg -O Wallpaper.jpg --limit-rate=10k
fi
	
if [ "$(md5sum /home/ventas/lotobet/.61606.png | awk 'NR==1 {print $1}')" != "366ae429b5871b3ca026f2ff5f2c433c" ]; then
	wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/LogoPrinter.png -O /home/ventas/lotobet/.61606.png --limit-rate=10k
fi

[ $? -eq 0 ] && [ $cambiar_fondo -eq 1 ] && pcmanfm --set-wallpaper "/home/ventas/.Auto/Wallpaper.jpg"       # Establecer Fondo de pantalla
#sed -i 's/.*desktop_fg=#.*/desktop_fg=#000000000000/' ~/.config/pcmanfm/LXDE-pi/desktop-items-0.conf    # Color letras escritorio

NewVersion=$(curl https://rapida.lotobet.net:61606/current.xml | grep -oP '(?<=<pkgver>).*?(?=</pkgver>)')
Version=$(cat /home/ventas/lotobet/current.xml | grep -oP '(?<=<pkgver>).*?(?=</pkgver>)')

if (( $(echo "$NewVersion > $Version" |bc -l) )) ;then
	wget -c https://rapida.lotobet.net:61606/LotobetClientExe.jar -P tmp/ --limit-rate=10k
	if [ $? -eq 0 ] ; then
		cp -f tmp/LotobetClientExe.jar /home/ventas/lotobet/LotobetClientExe.jar	
		if [ $? -eq 0 ]; then
			rm tmp/LotobetClientExe.jar
			wget https://rapida.lotobet.net:61606/current.xml -q -O- | tr -d '\r' >/home/ventas/lotobet/current.xml
		fi
	fi
fi
exit

