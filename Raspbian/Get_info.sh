#! /bin/bash
cd "$(dirname "$0")"
rm sed*
info=(
	Coneccion_Modem_PC
	Modem 
	Intercafe
	wifi_Signal
	wifi_Quality
	Telefonica
	Nivel_Senal
	Modelo_Dispositivo
	Codigo_SIM
	Senal_Ruido
	Id_Celda
	Disp_Conectados_Wifi
	Tarjeta_SIM
	Estado_Coneccion
	Red_Conectada
	Modo_Conec_Configurado
	Red_Configurada
	Modo_Busq_Red_Configurado
	Datos_Moviles
	)

file="$(cat info.ini)"
for i in "${info[@]}" ; do
	[[ "$file" == *"$i"* ]] || echo "$i=" >> info.ini
	
done
	
t0=0
interv=20	#minutos
while true ; do
	t1=$(date +%H%M)
	t_up=$((t0 + interv))
	t_dow=$((t0 - interv))
	if [[ "$t1" -lt "$t_dow" || "$t1" -gt "$t_up" ]]; then
		Coneccion_a_Modem="$(cat info.ini | grep 'Coneccion_Modem_PC=' | cut -d'=' -f2)"
		m_name="$(cat info.ini | grep 'Modem=' | cut -d'=' -f2)"
		if [[ "$Coneccion_a_Modem" == "True" ]]; then
			if [ -z "$(ps -ax |grep -v grep | grep 'python3 Modem.py')" ] ; then
				python3 Modem.py $m_name &
				echo "$m_name"
				t0=$(date +%H%M)
			fi
			
		fi
	fi
	
	route=$(ip route | grep default)
	ip=$(echo ${route##*'via '} | awk '{ print $1}')
	if ping $ip -i .2 -c 2 -w 1 -q >/dev/null ; then
		Coneccion_Modem_PC='True' 
	else
		Coneccion_Modem_PC='False'
	fi
	sed -i "s/^Coneccion_Modem_PC=.*/Coneccion_Modem_PC=$Coneccion_Modem_PC/" info.ini
	[[ "$route" == *"192.168.8.1"* ]] && modem='Huawei'
	[[ "$route" == *"192.168.1.1"* ]] && modem='Alcatel'
	sed -i "s/^Modem=.*/Modem=$modem/" info.ini
	interfece=$(echo $route | awk '{ print $5}')
	sed -i "s/^Intercafe=.*/Intercafe=$interfece/" info.ini
	wf=$(iwconfig wlan0 | grep 'Link Quality')
	wifi_Signal=$(echo ${wf##*'Signal level='} | awk '{ print $1}')
	wifi_Quality=$(echo ${wf##*'Link Quality='} | awk '{ print $1}' | cut -d/ -f1)
	sed -i "s/^wifi_Signal=.*/wifi_Signal=$wifi_Signal/" info.ini
	sed -i "s/^wifi_Quality=.*/wifi_Quality=$wifi_Quality/" info.ini
	echo '...'
	sleep 5
done
