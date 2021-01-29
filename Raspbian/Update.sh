#!/bin/bash
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Apagado.sh -q -O- | tr -d '\r' >/home/pi/Auto/Apagado.sh
[ $? -eq 0 ] && echo "version=1" > current.ini && rm Update.sh
exit
