#! /bin/bash
cd "$(dirname "$0")"
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/CanalWifi.py -O CanalWifi.py 
if [ $? -eq 0 ] ; then
	ip=$(ip route | grep default | awk '{print $3}')
    if [ $ip = "192.168.1.1" ] ; then
        python3 /home/ventas/.Auto/CanalWifi.py Alcatel &
    elif [ $ip = "192.168.8.1" ] ; then
        python3 /home/ventas/.Auto/CanalWifi.py Huawei &
    fi    
else
    exit
fi
sleep 30
while [ -z "$TIME" ]; do
	TIME="$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
	sleep 1
done
sleep 20
inf=986953837
URL="https://docs.google.com/forms/d/e/1FAIpQLSd0pRPkVt8oigNw-CZVuMyESFybTi1Me1ORbENgJWiuaothwg/formResponse"
. Current.ini
banca=${Banca}
memoria=$(free -ght | grep Total | awk '{print $2}')
Modelo=$(cat /sys/firmware/devicetree/base/model)
ip=$(ip route | grep default | awk '{print $3}')
interface=$(ip route | grep default | awk '{print $5}')
osversion=$(cat /etc/debian_version)
canal=$(iw wlan0 info | grep channel | awk '{print $2}')
curl $URL -d ifq \
	-d "entry.$inf=$banca|$Modelo|$osversion|$memoria|$interface|$ip|$canal" 

echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && echo "Tipo=$3" >> Current.ini && rm Update.sh && rm CanalWifi.py

exit
