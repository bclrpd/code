#! /bin/bash
cd "$(dirname "$0")"

function check_fecha {	
	if [ $1 == "Ayer" ] ; then 
		Fecha=$(date --date="-1 day" +%d-%m-%Y)
	elif [ $1 == "Hoy" ] ; then
		Fecha=$(date +%d-%m-%Y)
	else
		echo "error"
		exit
	fi
	}
	
function check_imprimiendo {
	imprimiendo=$(cat TicketPremios | grep "imprimiendo" | awk '{print $2}')
	echo "$imprimiendo"
	if [ "$imprimiendo" -gt 0 ]; then
		echo "imprimiendo $(($imprimiendo+1))" > TicketPremios
		if [ "$imprimiendo" -gt 6 ]; then	
			echo "" > TicketPremios
		fi
		echo $imprimiendo
		exit
	fi
}

function check_impresora_ocupada {
	A=$(lpstat Impresora | grep "Impresora" | awk '{print $1}')
	if [ ! -z "$A" ] ; then
		echo "Impresora Ocupada"
		exit -1
	fi
}

function descargar_premios {
	echo "  " > Premios.ini
	wget https://drive.google.com/u/0/uc?id=1xoK8xsJ014ijRmCHnP4ZNjyv_NTI7thh -O Premios.ini
	if [ $? -ne 0 ] ; then
		echo "" > TicketPremios
		exit
	fi
}

Dia=$1

check_fecha $Dia
check_imprimiendo
check_impresora_ocupada
echo "imprimiendo 1" > TicketPremios
descargar_premios

Premios="$( awk '/\[/{prefix=$0; next} $1{print prefix $0}' Premios.ini)"
Loterias=("Primera 12pm" "Primera 8pm" "Q Real" "Nac T" "Nac N"  "Loteka" "Q Pale" "Lotedom" "Suerte 12.30pm" "Suerte 6pm" "Ny Dia" "Ny Noche" "FL Tarde" "FL Noche" "Anguilla 10am" "Anguilla 1pm" "Anguilla 6pm" "Anguilla 9pm" "King Lot Dia" "King Lot Noche")

Array=()

for i in "${Loterias[@]}"; do	
	Q="$(echo "$Premios" | grep "$Fecha" | grep -i "$i" | awk -F"= " '{print $NF}')"
	if [ ! -z "$Q" ] ; then
		x=$((16 - ${#i}))
		f=$(eval printf '_%.0s' {1..$x}) #Puntos a imprimir	
		Pr="${Q//100/$'00'}"
		Pre="${Pr//,/$'-'}"
		Array+=("$i$f$Pre")
	fi

done
echo -e "Recibe los Premios por Whatsapp Escribiendo al" > TicketPremios
echo -e "\x1ba1\x1b!2809-486-6448\n" >> TicketPremios
echo -e "\x1ba1\x1b!2RESULTADOS" >> TicketPremios
echo -e "$Fecha" >> TicketPremios
echo -e "\x1ba0\x1b! " >> TicketPremios
for j in "${Array[@]}"; do
	echo $j >> TicketPremios
done
echo -e "\xa\xa\xa\xa" >> TicketPremios
echo -e "\x1bm" >> TicketPremios
lpr Logo
lpr TicketPremios
echo "Fin"
exit
