#!/bin/sh
cd "$(dirname "$0")"

until ping -nq -c3 8.8.8.8; do
	sleep 1
done

if [ "$(md5sum Wallpaper.jpg | awk 'NR==1 {print $1}')" != "f677f001374b7290683045b483067e35" ]; then
	wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Wallpaper.jpg -O Wallpaper.jpg --limit-rate=10k
fi
	
if [ "$(md5sum /home/ventas/lotobet/.61606.png | awk 'NR==1 {print $1}')" != "d43b9f2423088b8f6c8a6ce125a793f8" ]; then
	wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/LogoPrinter.png -O /home/ventas/lotobet/.61606.png --limit-rate=10k
fi

#[ $? -eq 0 ] && pcmanfm --set-wallpaper "/home/ventas/.Auto/Wallpaper.jpg"       # Establecer Fondo de pantalla
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

