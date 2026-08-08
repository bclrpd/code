#!/bin/sh
cd "$(dirname "$0")"
until ping -nq -c3 8.8.8.8; do
	sleep 1
done
mac_eth0="$(cat /sys/class/net/eth0/address)"
mac_wlan0="$(cat /sys/class/net/wlan0/address)"
lista=('b8:27:eb' 'dc:a6:32' 'e4:5f:01' '28:cd:c1' '2c:cf:67' 'd8:3a:dd' '88:a2:9e' '98:fe:54')
. Current.ini
banca="${Banca}"
tipo="${Tipo}"
pizarra=false
for i in {1..20}; do
	for i in {1..6}; do
		readarray -t mac_list < <(arp-scan --localnet -t 1000 -g -N --plain | cut -f 2)
		for mac in "${mac_list[@]}"; do
			if [ "$mac" != "$mac_eth0" ] && [ "$mac" != "$mac_wlan0" ]; then
				prefijo="${mac:0:8}"
				for oui in "${lista[@]}"; do
					if [ "$oui" == "$prefijo" ]; then
						pizarra=true
						#guardar en base de datos
						fecha=$(date +"%d-%m-%Y %H:%M:%S")
						datos="{\"Mac\": \"$mac\", \"Banca\": \"$banca\", \"Tipo\": \"$tipo\", \"Fecha\": \"$fecha\"}"
						curl -X POST "https://guardar-inf-pizarras-60149547169.us-east4.run.app" \
							-H "Content-Type: application/json" \
							-d "$datos" \
							--max-time 10
						break
					fi
				done
			fi
		done
		if [ "$pizarra" = true ]; then
			echo "Pizarra encontrada $mac"
			break
		else	
			echo "Pizarra NO encontrada"	
		fi
		sleep 30
	done

	if [ "$pizarra" = true ]; then
		break
	else
		echo "Cambiando Canal WIFI..."
		python3 Modem.py 'TCL' 'cambiar_canal'
		sleep 60
	fi
done
exit



#1e9e544039e5b1
	
