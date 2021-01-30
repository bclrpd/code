#!/bin/bash
cd "$(dirname "$0")"
X=0
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Apagado.sh -q -O- | tr -d '\r' >Apagado.sh
[ $? -eq 0 ] || X=1 
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/CloneMac.sh -q -O- | tr -d '\r' >CloneMac.sh
[ $? -eq 0 ] || X=1 
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Impresora.sh -q -O- | tr -d '\r' >Impresora.sh
[ $? -eq 0 ] || X=1 
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Inicio.sh -q -O- | tr -d '\r' >Inicio.sh
[ $? -eq 0 ] || X=1 
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Ping.sh -q -O- | tr -d '\r' >Ping.sh
[ $? -eq 0 ] || X=1 
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/ControlHorario.sh -q -O- | tr -d '\r' >ControlHorario.sh
[ $? -eq 0 ] || X=1 
[ $X -eq 0 ] && echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && rm Update.sh
exit
