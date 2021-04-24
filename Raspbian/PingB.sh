#! /bin/bash
#eliminar esta linea
sed -i 's/.*desktop_fg=#.*/desktop_fg=#000000000000/' ~/.config/pcmanfm/LXDE-pi/desktop-items-0.conf
#eliminar

cd "$(dirname "$0")"
xmodmap -e "pointer = 1 2 0"
bash Inicio.sh &
#bash Apagado.sh &
bash ControlHorario.sh &

while true ; do
if [ $(xprintidle) -lt 30000 ] ; then
ping 8.8.8.8 -i 0.2 -w 5 
else
sleep 1
fi
done

