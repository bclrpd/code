#! /bin/bash
cd "$(dirname "$0")"
xmodmap -e "pointer = 1 2 0"
#bash Pizarra/Start.sh &
#bash Mouse.sh &
bash Descargar.sh &
bash Inicio.sh &
bash Apagado.sh &
bash ControlHorario.sh &
bash Boton_Premios.sh &
bash Icono_network.sh &

while true ; do
if [ $(xprintidle) -lt 30000 ] ; then
ping 8.8.8.8 -i 0.2 -w 5 
else
sleep 1
fi
done

