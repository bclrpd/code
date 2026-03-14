#! /bin/bash
cd "$(dirname "$0")"
contador=1

Proceder(){
    estadistic=""
    pqtPerdidos=""
    modem="$(cat info.ini | grep 'Modem=' | cut -d'=' -f2)"
    red="$(cat info.ini | grep 'Red_Conectada=' | cut -d'=' -f2)"
    interface="$(cat info.ini | grep 'Intercafe=' | cut -d'=' -f2)"
    wifiSignal="$(cat info.ini | grep 'wifi_Signal=' | cut -d'=' -f2)"
    wifiQuality="$(cat info.ini | grep 'wifi_Quality=' | cut -d'=' -f2)"
    Nivel_Senal="$(cat info.ini | grep 'Nivel_Senal=' | cut -d'=' -f2)"
    Senal_Ruido="$(cat info.ini | grep 'Senal_Ruido=' | cut -d'=' -f2)"
    
    ping_result=$(ping 8.8.8.8 -i 0.2 -w 9 -q 2>&1)
    if [[ "$ping_result" == *"min/avg/max/mdev"* ]]; then
        estadistica=$(echo ${ping_result##*'mdev = '} | awk '{ print $1}')
    fi
    if [[ "$ping_result" == *"packet loss"* ]]; then 
        pqtPerdidos=$(echo ${ping_result%%'packet loss'*} | awk '{ print $NF}' | cut -d% -f1 )
        pqtPerdidos="$(printf '%.0f' $pqtPerdidos)"
    fi
    
    if [ -z "$pqtPerdidos" ] ; then
        echo "$(date +%FT%T)|$ping_result" | tr -d '\n' >> Registro_ping
        echo '' >> Registro_ping
        sleep 9
    else
        [[ "$pqtPerdidos" == "100" ]] && estadistica=''
        echo "$(date +%FT%T)|$modem|$red|$interface|$wifiSignal|$wifiQuality|$Nivel_Senal|$Senal_Ruido|$pqtPerdidos|$estadistica" >> Registro_ping
    fi
    }

[[ "$(file -bi Registro_ping)" == *"charset=binary" ]] && $(sed -i 's/\x0//g' Registro_ping) #Repara el archivo
while true ; do
    idle_time=$(xprintidle)
  
    if [ "$idle_time" -lt 60000 ] ; then
        contador=1
        Proceder

    elif [ "$idle_time" -gt $((contador * 30000)) ] ; then
        ((contador++))
        Proceder
    fi
    sleep 1
done

