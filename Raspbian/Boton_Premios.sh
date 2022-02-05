#! /bin/bash
cd "$(dirname "$0")"
until ping -nq -c3 8.8.8.8; do
	sleep 1
done

while true; do
Imprimir=$(yad --center --skip-taskbar --on-top --undecorated --geometry=+740+55 --button="Premios")
bash Imprimir.sh
done
