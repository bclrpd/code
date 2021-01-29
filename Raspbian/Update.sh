#!/bin/bash
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Apagado.sh -q -O- | tr -d '\r' >/home/pi/Auto/Apagado.sh
[ $? -eq 0 ] && echo "Version=1" > Current.ini && rm Update.sh
exit
