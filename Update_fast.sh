#! /bin/bash
cd "$(dirname "$0")"

function descargar_cliente {
	wget -c https://raw.githubusercontent.com/bclrpd/code/main/LotobetClientExe.jar -P tmp/
	if [ $? -eq 0 ] ; then
		cp -f tmp/LotobetClientExe.jar /home/ventas/lotobet/LotobetClientExe.jar
		if [ $? -eq 0 ]; then
			rm tmp/LotobetClientExe.jar
		else
			exit
		fi
	else
		exit
	fi
	}
V_Nueva=$1
function check_descargar_cliente {
	. Current.ini
	y=${Version}
	z=$(($y+1))
	if [ $V_Nueva -gt $z ]; then
		descargar_cliente
	fi
	}

check_descargar_cliente
	
URL=https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/
Archivo=(
    Apagado.sh 
    Boton_Premios.sh 
    CloneMac.sh 
    Descargar.sh 
    Get_info.sh 
    Icono_network.sh 
    Impresora.sh 
    Imprimir.sh Logo 
    Inicio.sh 
    Keep_Open.sh 
    Modem.py
    Monitorear_Coneccion.sh 
    Mouse.sh 
    Ping.sh 
    Reboot.py 
    ShutdownButton.sh 
    Sincronizar_Hora.sh 
    Subir_archivo.py 
    Tinta.sh 
    UpdateChek.sh
)

if [ "$3" == "B" ] ; then
	Archivo+=(ControlHorarioB.sh)
else
	Archivo+=(ControlHorario.sh)
fi

X=0
for i in "${Archivo[@]}"; do
	[ "$i" = "ControlHorarioB.sh" ] && curl -sfSL $URL$i | tr -d '\r' >tmp/ControlHorario.sh && continue
	curl -sfSL $URL$i | tr -d '\r' >tmp/$i
	[ $? -eq 0 ] || X=1
done

for i in "${Archivo[@]}"; do
    [ "$i" == "ControlHorarioB.sh" ] && i="ControlHorario.sh"
    if grep -q "1e9e544039e5b1" tmp/$i; then
        cp -f tmp/$i /home/ventas/.Auto/$i
        if [ $? -eq 0 ]; then
			rm tmp/$i
        else
             X=1
		fi  
    else
        X=1 
    fi        
done

curl -sfSL https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/current.xml | tr -d '\r' >/home/ventas/lotobet/current.xml
curl -sfSL https://raw.githubusercontent.com/bclrpd/code/main/panel | tr -d '\r' >/home/ventas/.config/lxpanel/LXDE-pi/panels/panel
gsettings set org.gnome.nm-applet show-applet false

[ $X -eq 0 ] && echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && echo "Tipo=$3" >> Current.ini && rm Update.sh && systemctl reboot -i

exit
