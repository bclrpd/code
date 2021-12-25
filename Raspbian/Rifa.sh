#! /bin/bash

until ping -nq -c3 8.8.8.8; do
	sleep 1
done

while true ; do
	if [ $(date +%w) -eq 0 ] ; then
		if [ $(date +%d%m%y) -eq 261221 ] ; then
			if [ $(date +%H%M) -gt 1750 ] ; then
				if [ $(date +%H%M) -lt 1800 ] ; then
						(
							T=$(</proc/uptime awk '{printf int ($1)}')
							X=$(echo "$(date +%H:%M:%S)" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
							Y=$((64800 - $X))
								while true ; do	
									D=$(($(</proc/uptime awk '{printf int ($1)}') - $T ))
									Timer=$(($Y - $D ))
									M=$(date -d@$Timer -u +%M)
									S=$(date -d@$Timer -u +%S)
									echo "# LA RIFA INICIARA EN $M m y $S s" 
									J=$(bc <<< "scale=2; ($D/$Y)*100")
									echo $J
									sleep 1

								done
						) | 
						yad --progress  --geometry 100x50+924+0 \
						--skip-taskbar --undecorated --on-top \
						--no-buttons --auto-close		
						
						#( xmodmap -e "pointer = 0 0 0" ; sleep 215 ; xmodmap -e "pointer = 1 2 3" ) &
						S="id="
						xinput | grep "keyboard" | while read -r line ; do
							if [[ $line != *"Virtual"* ]]; then
								#echo "$line"
								ID=$(echo ${line/*$S/$S} | awk '{print $1}' | tr -d $S)
								echo $ID
								#( xinput set-prop $ID 'Device Enabled' 0 ; sleep 215 ; xinput set-prop $ID 'Device Enabled' 1 ) &
							fi
							
							done
						omxplayer Rifa.mp4	
						
						
				else
					exit
				fi						
			else 
				echo 3
				sleep 10 
			fi
		else 
			echo 2
			sleep 600		
		fi
	else 
		echo 1
		sleep 600
	fi	
done

exit
