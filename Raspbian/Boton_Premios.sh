#! /bin/bash
cd "$(dirname "$0")"
until ping -nq -c3 8.8.8.8; do
	sleep 1
done

yad --text="Premios" --text-align=center --form --columns=2 \
--center --skip-taskbar --on-top --undecorated --geometry=+720+38 --no-buttons \
--field="Ayer":fbtn "bash Imprimir.sh Ayer" \
--field="Hoy":fbtn "bash Imprimir.sh Hoy"

exit
