#!/bin/bash
cd "$(dirname "$0")"
URL=https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/
if [ "$3" == "A" ] ; then
	Archivo=(ControlHorario.sh Apagado.sh CloneMac.sh Impresora.sh Inicio.sh Ping.sh ShutdownButton.sh)
else
	Archivo=(ControlHorarioB.sh Apagado.sh CloneMac.sh Impresora.sh Inicio.sh PingB.sh ShutdownButton.sh)
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
[ $X -eq 0 ] && echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && rm Update.sh


wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/LogoPrinter.png -O /home/ventas/lotobet/.61606.png
echo "aaaaaa"
[ $? -eq 0 ] && sed -i 's/.*desktop_fg=#.*/desktop_fg=#f684097b097b/' ~/.config/pcmanfm/LXDE-pi/desktop-items-0.conf
echo "bbbb"
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Wallpaper.jpg -O Wallpaper.jpg
[ $? -eq 0 ] && pcmanfm --set-wallpaper "/home/ventas/.Auto/Wallpaper.jpg"

exit
