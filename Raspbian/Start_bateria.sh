#!/bin/sh
cd "$(dirname "$0")"
until ping -nq -c3 8.8.8.8; do
	sleep 1
done
sleep 300
banca="$(cat Current.ini | grep 'Banca=' | cut -d'=' -f2)"
python3 Bateria.py "$banca"

#1e9e544039e5b1
