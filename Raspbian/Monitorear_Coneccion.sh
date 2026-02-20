#! /bin/bash
cd "$(dirname "$0")"
contador=1
while true ; do
    idle_time=$(xprintidle)
    if [ "$idle_time" -lt 60000 ] ; then
        contador=1
        ping_result=$(ping 8.8.8.8 -i 0.2 -w 10 -q)
        if [[ "$ping_result" == *"min/avg/max/mdev"* ]]; then
            estadistica=$(echo ${ping_result##*'mdev = '} | awk '{ print $1}')
            pqtPerdidos=$(echo ${ping_result%%'packet loss'*} | awk '{ print $NF}')
        elif [[ "$ping_result" == *"packet loss"* ]]; then 
            estadistica=""
            pqtPerdidos=$(echo ${ping_result%%'packet loss'*} | awk '{ print $NF}')
        else 
            estadistica=""
            pqtPerdidos=""
        fi
        
        if [ ! -z "$pqtPerdidos" ] ; then
            echo "$(date +%FT%T)/$pqtPerdidos/$estadistica" >> Registro_ping
        else
            echo "$(date +%FT%T)/$ping_result" | tr -d '\n' >> Registro_ping
            echo '' >> Registro_ping
            sleep 5
        fi
        
        echo $estadistica
        echo $pqtPerdidos
    elif [ "$idle_time" -gt $((contador * 30000)) ] ; then
        ((contador++))
        ping_result=$(ping 8.8.8.8 -i 0.2 -w 10 -q)
        if [[ "$ping_result" == *"min/avg/max/mdev"* ]]; then
            estadistica=$(echo ${ping_result##*'mdev = '} | awk '{ print $1}')
            pqtPerdidos=$(echo ${ping_result%%'packet loss'*} | awk '{ print $NF}')
        elif [[ "$ping_result" == *"packet loss"* ]]; then 
            estadistica=""
            pqtPerdidos=$(echo ${ping_result%%'packet loss'*} | awk '{ print $NF}')
        else 
            estadistica=""
            pqtPerdidos=""
        fi
        
        if [ ! -z "$pqtPerdidos" ] ; then
            echo "$(date +%FT%T)/$pqtPerdidos/$estadistica" >> Registro_ping
        else
            echo "$(date +%FT%T)/$ping_result" | tr -d '\n' >> Registro_ping
            echo '' >> Registro_ping
            sleep 5
        fi
    else
        sleep 1
    fi
done
