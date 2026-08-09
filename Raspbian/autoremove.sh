#! /bin/bash
# Se ejecuta desde el script Impresora.sh
cd "$(dirname "$0")"

sed -i '/0x2ca6 0x811a unidir/d' /usr/share/cups/usb/org.cups.usb-quirks
sleep 1
vendor=('0x0FE6 unidir soft-reset' '0x4B43 unidir' '0x2CA6 0x811A unidir soft-reset' '0x2CC8 0x811C unidir soft-reset')
for i in "${vendor[@]}" ; do
	existe=$(grep "$i" /usr/share/cups/usb/org.cups.usb-quirks)
	if [ -z "$existe" ] ; then
		echo "$i" >> /usr/share/cups/usb/org.cups.usb-quirks
	fi	
done

repositorios=('deb http://legacy.raspbian.org/raspbian/ buster main contrib non-free rpi' 'deb-src http://legacy.raspbian.org/raspbian/ buster main contrib non-free rpi' )
for i in "${repositorios[@]}" ; do
	existe=$(grep "$i" /etc/apt/sources.list)
	if [ -z "$existe" ] ; then
		echo "$i" >> /etc/apt/sources.list
	fi	
done

until ping -nq -c3 8.8.8.8; do
	sleep 1
done

sudo apt-get update -y -o Acquire::http::Dl-Limit=50
sudo apt install arp-scan -y -o Acquire::http::Dl-Limit=50
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/arp-scan
getcap /usr/sbin/arp-scan

if command -v arp-scan & > /dev/null; then
    rm autoremove.sh
fi


#1e9e544039e5b1
