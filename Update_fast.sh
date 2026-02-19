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
if [ "$3" == "B" ] ; then
	Archivo=(ControlHorarioB.sh Apagado.sh CloneMac.sh Impresora.sh Inicio.sh Ping.sh ShutdownButton.sh UpdateChek.sh Reboot.py Descargar.sh Boton_Premios.sh Imprimir.sh Logo Mouse.sh Tinta.sh Sincronizar_Hora.sh Keep_Open.sh Icono_network.sh Monitorear_Coneccion.sh Subir_archivo.py)
else
	Archivo=(ControlHorario.sh Apagado.sh CloneMac.sh Impresora.sh Inicio.sh Ping.sh ShutdownButton.sh UpdateChek.sh Reboot.py Descargar.sh Boton_Premios.sh Imprimir.sh Logo Mouse.sh Tinta.sh Sincronizar_Hora.sh Keep_Open.sh Icono_network.sh Monitorear_Coneccion.sh Subir_archivo.py)
fi

X=0
for i in "${Archivo[@]}"; do
	wget -q --method HEAD $URL$i
	if [ $? -eq 0 ] ; then
		[ "$i" = "ControlHorarioB.sh" ] && wget $URL$i -q -O- | tr -d '\r' >tmp/ControlHorario.sh && continue
		wget $URL$i -q -O- | tr -d '\r' >tmp/$i
		[ $? -eq 0 ] || X=1
	fi
done

for i in "${Archivo[@]}"; do
    [ "$i" == "ControlHorarioB.sh" ] && i="ControlHorario.sh"
    if [ $(stat -c%s tmp/$i) -gt 100 ] ; then
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

wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/current.xml -q -O- | tr -d '\r' >/home/ventas/lotobet/current.xml
wget https://raw.githubusercontent.com/bclrpd/code/main/panel -q -O- | tr -d '\r' >/home/ventas/.config/lxpanel/LXDE-pi/panels/panel
gsettings set org.gnome.nm-applet show-applet false

[ $X -eq 0 ] && echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && echo "Tipo=$3" >> Current.ini && rm Update.sh && systemctl reboot -i

exit
