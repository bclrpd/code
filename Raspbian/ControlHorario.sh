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

function Mostrar_Mensage_Tardanza() {
	Hora1=$1
	Hora2=$2
	
	Colores=("yellow" "blue" "red")
	Color=$(echo $(($RANDOM%3)))
	case $Color in
		0) convert -size 1024x768  xc:yellow msg/ImagenBase.jpg;;
		1) convert -size 1024x768  xc:blue msg/ImagenBase.jpg ;;	
		2) convert -size 1024x768  xc:red msg/ImagenBase.jpg;;
		*) convert -size 1024x768  xc:red msg/ImagenBase.jpg;;
	esac

	TEXT="<span font='80' foreground='red' ><b>     $Hora2     </b></span>\n<span font='22' foreground='blue' >Recuerda que la hora de abrir la banca es a  las $Hora1, abrir después de esa hora es considerado tardanza.\n\nTen en cuenta que todos los días se registra la hora a la que abres la banca y cada vez que llegas después de las $Hora1 se registra como tardanza.\n\nDe ti depende que esto no suceda de nuevo, puesto que las tardanzas no serán toleradas.\n</span>"

# yellow, lime, black ivory

	convert  -font verdana -background ivory -size 700 -define pango:justify=true pango:"$TEXT" msg/ImagenTexto.jpg
	convert msg/ImagenBase.jpg msg/ImagenTexto.jpg -gravity center -composite -matte msg/output.jpg
	
	yad --image="msg/output.jpg" --geometry 1024 --image-on-top \
	--skip-taskbar --undecorated --on-top \
	--button=gtk-ok  --buttons-layout=center
}



while true ; do

	until ping -nq -c3 8.8.8.8; do
		echo "TIEMPO=$((ACUMULADO+$(</proc/uptime awk '{printf int ($1)}')))" > Data.ini
		sleep 1
	done
	while [ -z "$TIME" ]; do
		echo "TIEMPO=$((ACUMULADO+$(</proc/uptime awk '{printf int ($1)}')))" > Data.ini
		TIME="$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
		sleep 1
	done

		Segundos=$(($ACUMULADO + $(</proc/uptime awk '{print int ($1)}')))
		Hora=$(date -d "$TIME" +%T)
		Fecha=$(date -d "$TIME" +%m/%d/%Y)
		HoraAbrio=$(date -d "$TIME - $Segundos seconds" +%T)	
		. Current.ini	
		if [ $(date --date "$Hora" +%H%M) -lt 1300 ] ;then
		
			Z="$(grep "$Fecha"_1 -w < Registro)"
			[[ "$Z" == *"$Fecha"* ]] && break
			
			[ -z "$(grep "$Fecha"_1 -w < Registro)" ] || break
			
			if [ $(date --date "$HoraAbrio" +%H%M) -ge 0855 ] ;then
				
				Mostrar=False
				for i in {1..4} ; do
					Z2="$(grep "$(date -d "$TIME - $i days" +%m/%d/%Y)"_1 -w < Registro)"
					[[ "$Z2" == *"TARDE"* ]] && Mostrar=True
				done

				if [ "$Mostrar" = "True" ] ; then
					Mostrar_Mensage_Tardanza '8:45' $(date -d "$HoraAbrio" +%l:%M)
					Razon=""
				
					echo "$Fecha""_1=$HoraAbrio|TARDE|$Razon" >> Registro
					echo "TIEMPO=0" > Data.ini
				
				else
					Razon="No Aplica"
					echo "$Fecha""_1=$HoraAbrio|TARDE|$Razon" >> Registro
					echo "TIEMPO=0" > Data.ini
				fi
										
				curl $URL -d ifq \
				-d "entry.$FECHA=$(date --date $Fecha +%d/%m/%Y)" \
				-d "entry.$BANCA=${Banca}" \
				-d "entry.$TURNO=Entrada 1" \
				-d "entry.$HORA=$HoraAbrio" \
				-d "entry.$PUNTUAL=NO" \
				-d "entry.$RAZON=$Razon"
						
				break			
				
			elif [ $(date --date "$HoraAbrio" +%H%M) -lt 0855 ] ;then
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
				
				Z="$(grep "$Fecha"_2 -w < Registro)"
				[[ "$Z" == *"$Fecha"* ]] && break
				
				[ -z "$(grep "$Fecha"_2 -w < Registro)" ] || break

				if [ $(date --date "$HoraAbrio" +%H%M) -ge 1710 ] ;then
					Mostrar=False
					for i in {1..4} ; do
						Z2="$(grep "$(date -d "$TIME - $i days" +%m/%d/%Y)"_2 -w < Registro)"
						[[ "$Z2" == *"TARDE"* ]] && Mostrar=True
					done

					if [ "$Mostrar" = "True" ] ; then
						Mostrar_Mensage_Tardanza '5:00' $(date -d "$HoraAbrio" +%l:%M)
						Razon=""
	
						echo "$Fecha""_2=$HoraAbrio|TARDE|$Razon" >> Registro
						echo "TIEMPO=0" > Data.ini	
					
						
					else
						Razon="No Aplica"
						echo "$Fecha""_2=$HoraAbrio|TARDE|$Razon" >> Registro
						echo "TIEMPO=0" > Data.ini	
					fi
								
					curl $URL -d ifq \
					-d "entry.$FECHA=$(date --date $Fecha +%d/%m/%Y)" \
					-d "entry.$BANCA=${Banca}" \
					-d "entry.$TURNO=Entrada 2" \
					-d "entry.$HORA=$HoraAbrio" \
					-d "entry.$PUNTUAL=NO" \
					-d "entry.$RAZON=$Razon"
									
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
	
echo "TIEMPO=$((ACUMULADO+$(</proc/uptime awk '{printf int ($1)}')))" > Data.ini
sleep 5
done
echo "TIEMPO=0" > Data.ini

exit
