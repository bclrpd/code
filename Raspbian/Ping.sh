#! /bin/bash
cd "$(dirname "$0")"
xmodmap -e "pointer = 1 2 0"
bash Inicio.sh &
bash Apagado.sh &

while true ; do
if [ $(xprintidle) -lt 30000 ] ; then
ping 8.8.8.8 -i 0.2 -w 5 
else
sleep 1
fi
done

