#! /bin/bash
cd "$(dirname "$0")"
while true; do
Imprimir=$(yad --center --skip-taskbar --on-top --undecorated --geometry=+740+55 --button="Premios")
bash Imprimir.sh
done
