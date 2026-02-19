#! /bin/bash
cd "$(dirname "$0")"
contador=1
while true ; do
    idle_time=$(xprintidle)
    if [ "$idle_time" -lt 60000 ] ; then
        contador=1
        ping_result=$(ping 8.8.8.8 -i 0.2 -w 10 -q)
        lista=( $ping_result )
        if  [ ${#lista[@]} -gt 16 ] ; then
            echo "$(date +%FT%T)/${lista[17]//%/}/${lista[25]}" >> Registro_ping
        fi
    elif [ "$idle_time" -gt $((contador * 30000)) ] ; then
        ((contador++))
        ping_result=$(ping 8.8.8.8 -i 0.2 -w 10 -q)
        lista=( $ping_result ) 
        if  [ ${#lista[@]} -gt 16 ] ; then
            echo "$(date +%FT%T)/${lista[17]//%/}/${lista[25]}" >> Registro_ping
        fi
    else
        sleep 1
    fi
done
