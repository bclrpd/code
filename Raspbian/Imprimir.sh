#! /bin/bash
cd "$(dirname "$0")"
A=$(lpstat Impresora | grep "Impresora" | awk '{print $1}')
if [ ! -z "$A" ] ; then
	echo "Impresora Ocupada"
	exit -1
fi

echo "  " > Premios.ini
wget https://drive.google.com/u/0/uc?id=1xoK8xsJ014ijRmCHnP4ZNjyv_NTI7thh -O Premios.ini
[ $? -eq 0 ] || exit 0
Premios="$( awk '/\[/{prefix=$0; next} $1{print prefix $0}' Premios.ini)"
Loterias=("La Primera 12pm" "La Primera 8pm" "Q Real" "Nac T" "Nac N" "Suerte 12.30pm" "Suerte 6pm" "Loteka" "Q Pale" "Lotedom" "Ny Dia" "Ny Noche" "FL Tarde" "FL Noche" "Anguilla 10am" "Anguilla 1pm" "Anguilla 6pm" "Anguilla 9pm")

if [ $(date +%H%M) -lt 1200 ] ; then 
	Fecha=$(date --date="-1 day" +%d-%m-%Y)
else
	Fecha=$(date +%d-%m-%Y)
fi

Array=()

for i in "${Loterias[@]}"
do	
	echo $i
	Q="$(echo "$Premios" | grep "$Fecha" | grep -i "$i" | awk -F"= " '{print $NF}')"
	
	if [ ! -z "$Q" ] ; then
		x=$((16 - ${#i}))
		f=$(eval printf '_%.0s' {1..$x}) #Puntos a imprimir	
		Pr="${Q//100/$'00'}"
		Pre="${Pr//,/$'-'}"
		Array+=("$i$f$Pre")
	fi

done
echo -e "\x1ba1\x1b!2RESULTADOS" > TicketPremios
echo -e "$Fecha" >> TicketPremios
echo -e "\x1ba0\x1b! " >> TicketPremios
for j in "${Array[@]}"
do
	echo $j >> TicketPremios
done
echo -e "\xa\xa\xa\xa" >> TicketPremios
echo -e "\x1bm" >> TicketPremios
lpr Logo
lpr TicketPremios
echo "Fin"
exit
