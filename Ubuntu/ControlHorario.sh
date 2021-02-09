#! /bin/bash
cd "$(dirname "$0")"

FECHA=1094993008
BANCA=1475362797
TURNO=1178772187 #("Entrada 1" o "Entrada 2")
HORA=1549658220
PUNTUAL=231354200 #(SI o NO)
RAZON=430411897
URL="https://docs.google.com/forms/d/e/1FAIpQLScaQs1b41h3mIVMsn6wNscjKLzeGVMXSc7xgD4W3VTh-mvtKw/formResponse"
X=$(xdpyinfo | awk '/dimensions/{print $2}' | awk -F "x" '{print $1}')
PX=$((($X-1024)/2))
[ -f Registro ] || echo "  Fecha    HORA    T       Razon" > Registro
[ -f Data.ini ] || echo "TIEMPO=0" > Data.ini
. Data.ini
ACUMULADO=${TIEMPO}

while true ; do
	TIME="$(cat </dev/tcp/time.nist.gov/13)"
	if [[ "$TIME" == *"UTC(NIST)"* ]] ; then
		Segundos=$(($ACUMULADO + $(</proc/uptime awk '{print int ($1)}')))
		Array=($TIME)
		Hora=$(date --date "${Array[2]} today - 240 minutes" +%T)
		HoraAbrio=$(date --date "$Hora today - $Segundos seconds" +%T)
		Fecha=$(date -d"${Array[1]} ${Array[2]} today - 240 minutes" +%m/%d/%Y)		
		. Current.ini
		if [ $(date --date "$Hora" +%H%M) -lt 1300 ] ;then
			[ -z "$(grep "$Fecha"_1 -w < Registro)" ] || break
			
			if [ $(date --date "$HoraAbrio" +%H%M) -ge 0840 ] ;then
				TEXT="<span font='30' foreground='red' ><b>LA HORA DE ABRIR LA BANCA ES A LAS <big><big><big><sub>\
<span bgcolor='aqua'>8:30 am</span></sub></big></big></big></b>  \n</span> \
<span font='22' foreground='black' >Vemos pertinente recordarle que debe cumplir el horario \
de trabajo estipulado por las normas de la empresa, ya que, de no poseer una justificación correcta, \
podría ameritar la aplicación de sanciones.\n</span>"

				convert  -font times -background white -size 1024 -define pango:justify=true pango:"$TEXT" Imagen.jpg
							
				Mensage=$(yad --image="Imagen.jpg"  --geometry 1024x200+$PX+30 --image-on-top \
				--skip-taskbar --undecorated --on-top \
				--form --field="<span font='time 15' foreground='blue'><b>Puedes escribir el motivo de la tardanza aqui.</b></span> ":LBL --field="" \
				--button=gtk-ok  --buttons-layout=center )
				Razon=$(echo $Mensage | awk -F "|" '{print $2}')
				
				echo "$Fecha""_1=$HoraAbrio|TARDE|$Razon" >> Registro
				echo "TIEMPO=0" > Data.ini
				curl $URL -d ifq \
				-d "entry.$FECHA=$(date --date $Fecha +%d/%m/%Y)" \
				-d "entry.$BANCA=${Banca}" \
				-d "entry.$TURNO=Entrada 1" \
				-d "entry.$HORA=$HoraAbrio" \
				-d "entry.$PUNTUAL=NO" \
				-d "entry.$RAZON=$Razon"
				
				TEXT3="<span size='25600' rise='-20480' foreground='blue' >Te exhortamos cumplir con el horario correspondiente y evitar incurrir en faltas en futuras ocasiones.</span>"
				convert -background linen -size 650 -define pango:justify=true pango:"$TEXT3" Imagen2.jpg
				yad --image="Imagen2.jpg" --no-buttons --undecorated --skip-taskbar --center  --timeout=7 --on-top	
				
				break			
				
			elif [ $(date --date "$HoraAbrio" +%H%M) -lt 0840 ] ;then
				echo "$Fecha""_1=$HoraAbrio|OK" >> Registro	
				echo "TIEMPO=0" > Data.ini
				curl $URL -d ifq \
				-d "entry.$FECHA=$(date --date $Fecha +%d/%m/%Y)" \
				-d "entry.$BANCA=${Banca}" \
				-d "entry.$TURNO=Entrada 1" \
				-d "entry.$HORA=$HoraAbrio" \
				-d "entry.$PUNTUAL=SI"		
				break
			fi					
		
		else
		
			if [ $(date --date "$Hora" +%H%M) -gt 1600 ] ;then
				[ $(date +%w) -eq 0 ] && break
				[ -z "$(grep "$Fecha"_2 -w < Registro)" ] || break
			
				if [ $(date --date "$HoraAbrio" +%H%M) -ge 1710 ] ;then
					TEXT="<span font='30' foreground='red' ><b>LA HORA DE ABRIR LA BANCA ES A LAS <big><big><big><sub>\
<span bgcolor='aqua'>5:00 pm</span></sub></big></big></big></b>  \n</span> \
<span font='22' foreground='black' >Vemos pertinente recordarle que debe cumplir el horario \
de trabajo estipulado por las normas de la empresa, ya que, de no poseer una justificación correcta, \
podría ameritar la aplicación de sanciones.\n</span>"

					convert  -font times -background white -size 1024 -define pango:justify=true pango:"$TEXT" Imagen.jpg
							
					Mensage=$(yad --image="Imagen.jpg"  --geometry 1024x200+$PX+30 --image-on-top \
					--skip-taskbar --undecorated --on-top \
					--form --field="<span font='time 15' foreground='blue'><b>Puedes escribir el motivo de la tardanza aqui.</b></span> ":LBL --field="" \
					--button=gtk-ok  --buttons-layout=center )
					Razon=$(echo $Mensage | awk -F "|" '{print $2}')
	
					echo "$Fecha""_2=$HoraAbrio|TARDE|$Razon" >> Registro
					echo "TIEMPO=0" > Data.ini	
					curl $URL -d ifq \
					-d "entry.$FECHA=$(date --date $Fecha +%d/%m/%Y)" \
					-d "entry.$BANCA=${Banca}" \
					-d "entry.$TURNO=Entrada 2" \
					-d "entry.$HORA=$HoraAbrio" \
					-d "entry.$PUNTUAL=NO" \
					-d "entry.$RAZON=$Razon"
					
					TEXT3="<span size='25600' rise='-20480' foreground='blue' >Te exhortamos cumplir con el horario correspondiente y evitar incurrir en faltas en futuras ocasiones.</span>"
					convert -background linen -size 650 -define pango:justify=true pango:"$TEXT3" Imagen2.jpg
					yad --image="Imagen2.jpg" --no-buttons --undecorated --skip-taskbar --center  --timeout=7 --on-top
					
					break
				
				elif [ $(date --date "$HoraAbrio" +%H%M) -lt 1710 ] ;then
	
					echo "$Fecha""_2=$HoraAbrio|OK" >> Registro
					echo "TIEMPO=0" > Data.ini
					curl $URL -d ifq \
					-d "entry.$FECHA=$(date --date $Fecha +%d/%m/%Y)" \
					-d "entry.$BANCA=${Banca}" \
					-d "entry.$TURNO=Entrada 2" \
					-d "entry.$HORA=$HoraAbrio" \
					-d "entry.$PUNTUAL=SI"			
					
					break	
							
				fi	
			else
			
				break
			
			fi
			
		fi

	fi
echo "TIEMPO=$((ACUMULADO+$(</proc/uptime awk '{printf int ($1)}')))" > Data.ini
sleep 5
done
echo "TIEMPO=0" > Data.ini

exit
