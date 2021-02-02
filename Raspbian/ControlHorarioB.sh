#! /bin/bash
cd "$(dirname "$0")"

#$(</proc/uptime awk '{print int ($1)}') // tiempo encendida
. Data.ini
[ $? -ne 0 ] && echo "TIEMPO=0" > Data.ini && . Data.ini
ACUMULADO=${TIEMPO}
while true ; do
	TIME=$(cat </dev/tcp/time.nist.gov/13)
	if [ $? -eq 0 ] ; then
		Segundos=$(($ACUMULADO + $(</proc/uptime awk '{print int ($1)}')))
		Array=($TIME)
		Hora=$(date --date "${Array[2]} today - 240 minutes" +%T)
		HoraAbrio=$(date --date "$Hora today - $Segundos seconds" +%T)
		Fecha=$(date -d"${Array[1]} ${Array[2]} today - 240 minutes" +%m/%d/%Y)	
		Year=$(date --date "$Fecha" +%Y)
		Mes=$(date --date "$Fecha" +%m)
		Dia=$(date --date "$Fecha" +%d)		
		
		[ "$(xmlstarlet sel -t -v "count(/Data/Year[@ID=$Year])" Doc.xml)" -eq 0 ] && xmlstarlet ed -L \
			-s /Data -t elem -n "YearTMP" -v "" \
			-i //YearTMP -t attr -n "ID" -v "$Year" \
			-r //YearTMP -v "Year" Doc.xml
		[ "$(xmlstarlet sel -t -v "count(/Data/Year[@ID=$Year]/Mes[@ID=$Mes])" Doc.xml)" -eq 0 ] && xmlstarlet ed -L \
			-s /Data/Year[@ID=$Year] -t elem -n "MesTMP" -v "" \
			-i //MesTMP -t attr -n "ID" -v "$Mes" \
			-r //MesTMP -v "Mes" Doc.xml
		
		[ "$(xmlstarlet sel -t -v "count(/Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia])" Doc.xml)" -eq 0 ] && xmlstarlet ed -L \
			-s /Data/Year[@ID=$Year]/Mes[@ID=$Mes] -t elem -n "DiaTMP" -v "" \
			-i //DiaTMP -t attr -n "ID" -v "$Dia" \
			-r //DiaTMP -v "Dia" \
			-s /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia] -t elem -n "MANANA" -v "" \
			-s /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/* -t elem -n Hora -v "" \
			-s /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/* -t elem -n Tardanza -v "" \
			-s /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/* -t elem -n Excuza -v "" \
			Doc.xml

		if [ $(date --date "$HoraAbrio" +%H%M) -lt 1300 ] ;then
			
			[ -z "$(xmlstarlet sel -t -v /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/MANANA/Hora Doc.xml)" ] || { echo "TIEMPO=0" > Data.ini && break; }
			
			. Current.ini
			
			if [ $(date --date "$HoraAbrio" +%H%M) -ge 0810 ] ;then
				TEXT="LA HORA DE ABRIR LA BANCA ES A LAS 8:30 am"
				TEXT2="Vemos pertinente recordarle que debe cumplir el horario de trabajo\n estipulado por las normas de la empresa, ya  que, de no poseer una\n justificación correcta, podría ameritar la aplicación de sanciones."
				convert -size 1080x200 xc:powderblue -font helvetica -fill blue -gravity north -pointsize 40 -annotate +0+20 "$TEXT" \
				-font arial -fill blue -pointsize 28 -gravity north -annotate +0+75 "$TEXT2" Imagen.jpg
				
				
				Mensage=$(yad --image="Imagen.jpg"  --geometry 1080x200+0+30 --image-on-top \
					--skip-taskbar --undecorated --on-top \
					--form --field="Puedes escribir el motivo de la tardanza aqui.":LBL --field="" \
					--button=gtk-ok  --buttons-layout=center )
				Razon=$(echo $Mensage | awk -F "|" '{print $2}')
				
				xmlstarlet ed -L \
				-u /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/MANANA/Hora -v "$HoraAbrio" \
				-u /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/MANANA/Tardanza -v "True" \
				-u /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/MANANA/Excuza -v "$Razon" \
				Doc.xml
				
				TEXT3="<span size='25600' rise='-20480' foreground='blue' >Te exhortamos cumplir con el horario correspondiente y evitar incurrir en faltas en futuras ocasiones.</span>"
				convert -background linen -size 650 -define pango:justify=true pango:"$TEXT3" Imagen2.jpg
				yad --image="Imagen2.jpg" --no-buttons --undecorated --skip-taskbar --center  --timeout=5
				
				echo "TIEMPO=0" > Data.ini
				echo "Banca=${Banca} Turno=1 Hora=$HoraAbrio Tardanza=True Razon=$Razon" | mutt -s "Banca ${Banca}" -- bancalarapidamail@gmail.com
				
			elif [ $(date --date "$HoraAbrio" +%H%M) -lt 0810 ] ;then
				xmlstarlet ed -L \
				-u /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/MANANA/Hora -v "$HoraAbrio" \
				-u /Data/Year[@ID=$Year]/Mes[@ID=$Mes]/Dia[@ID=$Dia]/MANANA/Tardanza -v "False" \
				Doc.xml
				echo "TIEMPO=0" > Data.ini
				echo "Banca=${Banca} Turno=1 Hora=$HoraAbrio Tardanza=False" | mutt -s "Banca ${Banca}" -- bancalarapidamail@gmail.com
			fi					
		
		
		fi
	
    break
	fi
echo "TIEMPO=$((ACUMULADO+$(</proc/uptime awk '{printf int ($1)}')))" > Data.ini
sleep 2
done
