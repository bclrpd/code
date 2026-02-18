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
bash Monitorear_Coneccion.sh &


