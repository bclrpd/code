#! /bin/bash
cd "$(dirname "$0")"
echo "1" >> aa
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/CanalWifi.py -O CanalWifi.py 
if [ $? -eq 0 ] ; then
echo "2" >> aa
	ip=$(ip route | grep default | awk '{print $3}')
    if [ $ip = "192.168.1.1" ] ; then
    	echo "2.1" >> aa
        lxterminal -e "python3 /home/ventas/.Auto/CanalWifi.py Alcatel" 
	echo "2.2" >> aa
    elif [ $ip = "192.168.8.1" ] ; then
        python3 /home/ventas/.Auto/CanalWifi.py Huawei 
    fi    
else
    exit
    echo "3" >> aa
fi
echo "4" >> aa
sleep 30

until ping -nq -c3 8.8.8.8; do
	sleep 1
done
echo "5" >> aa
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

echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && echo "Tipo=$3" >> Current.ini && rm Update.sh

exit
