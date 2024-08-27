#!/bin/bash
cd "$(dirname "$0")"
URL=https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/
if [ "$3" == "A" ] ; then
	Archivo=(ControlHorario.sh Apagado.sh CloneMac.sh Impresora.sh Inicio.sh Ping.sh ShutdownButton.sh UpdateChek.sh Reboot.py Descargar.sh Boton_Premios.sh Imprimir.sh Logo Mouse.sh Tinta.sh)
else
	Archivo=(ControlHorarioB.sh Apagado.sh CloneMac.sh Impresora.sh Inicio.sh Ping.sh ShutdownButton.sh UpdateChek.sh Reboot.py Descargar.sh Boton_Premios.sh Imprimir.sh Logo Mouse.sh Tinta.sh)
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
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/current.xml -q -O- | tr -d '\r' >/home/ventas/lotobet/current.xml
#-----------------Estas Linenas se borraran en la primera ejecucion---------------------------------
wget -c wget https://raw.githubusercontent.com/bclrpd/code/main/LotobetClientExe.jar -P tmp/
if [ $? -eq 0 ] ; then
	cp -f tmp/LotobetClientExe.jar /home/ventas/lotobet/LotobetClientExe.jar
	if [ $? -eq 0 ]; then
		rm tmp/LotobetClientExe.jar
		sed -i '7,168' ./Descargar.sh
		systemctl reboot -i
	fi
fi
#-----------------Estas Linenas se borraran en la primera ejecucion---------------------------------
[ $X -eq 0 ] && echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && echo "Tipo=$3" >> Current.ini && rm Update.sh

#-----------------------------
pcmanfm --set-wallpaper "/home/ventas/.Auto/Wallpaper.jpg"
sleep 1
systemctl reboot -i
#--------------------

exit
