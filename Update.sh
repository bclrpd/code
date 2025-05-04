#! /bin/bash
cd "$(dirname "$0")"

inf=986953837
URL="https://docs.google.com/forms/d/e/1FAIpQLSd0pRPkVt8oigNw-CZVuMyESFybTi1Me1ORbENgJWiuaothwg/formResponse"
. Current.ini
banca=${Banca}
memoria=$(free -ght | grep Total | awk '{print $2}')
Modelo=$(cat /sys/firmware/devicetree/base/model)
ip=$(ip route | grep default | awk '{print $3}')
interface=$(ip route | grep default | awk '{print $5}')
osversion=$(cat /etc/debian_version)

curl $URL -d ifq \
	-d "entry.$inf=$banca|$Modelo|$osversion|$memoria|$interface|$ip" 

echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && echo "Tipo=$3" >> Current.ini && rm Update.sh

exit
