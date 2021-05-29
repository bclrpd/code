#!/bin/bash
cd "$(dirname "$0")"
URL=https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/
if [ "$3" == "A" ] ; then
	Archivo=(ControlHorario.sh Apagado.sh CloneMac.sh Impresora.sh Inicio.sh Ping.sh ShutdownButton.sh UpdateChek.sh Reboot.py chromium-browser Descargar.sh)
else
	Archivo=(ControlHorarioB.sh Apagado.sh CloneMac.sh Impresora.sh Inicio.sh PingB.sh ShutdownButton.sh UpdateChek.sh Reboot.py chromium-browser Descargar.sh)
fi

X=0
for i in "${Archivo[@]}"
do
	wget -q --method HEAD $URL$i
	if [ $? -eq 0 ] ; then
		[ "$i" = "ControlHorarioB.sh" ] && wget $URL$i -q -O- | tr -d '\r' >ControlHorario.sh && continue
		[ "$i" = "PingB.sh" ] && wget $URL$i -q -O- | tr -d '\r' >Ping.sh && continue
		wget $URL$i -q -O- | tr -d '\r' >$i
		[ $? -eq 0 ] || X=1 
	fi
done
[ $X -eq 0 ] && echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && echo "Tipo=$3" >> Current.ini && rm Update.sh

if [ "$(md5sum Wallpaper.jpg | awk 'NR==1 {print $1}')" != "f677f001374b7290683045b483067e35" ]; then
	wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Wallpaper.jpg -O Wallpaper.jpg --limit-rate=10k
fi
	
if [ "$(md5sum /home/ventas/lotobet/.61606.png | awk 'NR==1 {print $1}')" != "d43b9f2423088b8f6c8a6ce125a793f8" ]; then
	wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/LogoPrinter.png -O /home/ventas/lotobet/.61606.png --limit-rate=10k
fi

[ $? -eq 0 ] && pcmanfm --set-wallpaper "/home/ventas/.Auto/Wallpaper.jpg"
exit
