#! /bin/bash
sleep 10
cd "$(dirname "$0")"

bash Inicio.sh &
bash Apagado.sh &
bash ControlHorario.sh &
while true ; do
if [ $(xprintidle) -lt 30000 ] ; then
ping 8.8.8.8 -s 8 -i 0.6 -w 5 
else
sleep 1
fi
done

