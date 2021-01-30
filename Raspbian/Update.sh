#!/bin/bash
cd "$(dirname "$0")"
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Apagado.sh -q -O- | tr -d '\r' >/home/pi/Auto/Apagado.sh
[ $? -eq 0 ] && echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && rm Update.sh
exit
