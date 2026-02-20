#! /bin/bash
cd "$(dirname "$0")"
contador=1
while true ; do
    idle_time=$(xprintidle)
    estadistic=""
    pqtPerdidos=""
    if [ "$idle_time" -lt 60000 ] ; then
        contador=1
        ping_result=$(ping 8.8.8.8 -i 0.2 -w 10 -q 2>&1)
        if [[ "$ping_result" == *"min/avg/max/mdev"* ]]; then
            estadistica=$(echo ${ping_result##*'mdev = '} | awk '{ print $1}')
        fi
        if [[ "$ping_result" == *"packet loss"* ]]; then 
            pqtPerdidos=$(echo ${ping_result%%'packet loss'*} | awk '{ print $NF}')
        fi
        
        if [ -z "$pqtPerdidos" ] ; then
            echo "$(date +%FT%T)/$ping_result" | tr -d '\n' >> Registro_ping
            echo '' >> Registro_ping
            sleep 10
        else
            echo "$(date +%FT%T)/$pqtPerdidos/$estadistica" >> Registro_ping
        fi

    elif [ "$idle_time" -gt $((contador * 30000)) ] ; then
        ((contador++))
        ping_result=$(ping 8.8.8.8 -i 0.2 -w 10 -q 2>&1)
        if [[ "$ping_result" == *"min/avg/max/mdev"* ]]; then
            estadistica=$(echo ${ping_result##*'mdev = '} | awk '{ print $1}')
        fi
        if [[ "$ping_result" == *"packet loss"* ]]; then 
            pqtPerdidos=$(echo ${ping_result%%'packet loss'*} | awk '{ print $NF}')
        fi
        
        if [ -z "$pqtPerdidos" ] ; then
            echo "$(date +%FT%T)/$ping_result" | tr -d '\n' >> Registro_ping
            echo '' >> Registro_ping
            sleep 10
        else
            echo "$(date +%FT%T)/$pqtPerdidos/$estadistica" >> Registro_ping
        fi  
    fi
    sleep 1
done
