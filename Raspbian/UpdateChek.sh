#! /bin/bash
cd "$(dirname "$0")"
A1=(134 1320 1310 1326 144 1420 1410 1426 154 1520 1720 1710 1726 184 1820 1810)
A2=(135 1321 1311 130 145 1421 1411 140 155 1521 1721 1711 170 185 1821 1811)
B1=(1 5 9 13 17 21 25 3 7 11 5 9 13 17 21 25)
B2=(2 6 10 14 18 22 26 4 8 12 6 10 14 18 22 26)
C1=(23 24 25 26 0 1 2 3 4 5 2 3 4 5 6 7)
MAC=$(nmcli d show eth0 | grep GENERAL.HWADDR: | awk '{print $2}' | tr -d : | grep -o .)
MAC2=($MAC)

#MAC=(0 1 2 | 3 4 5 | 6 7 8 | 9 10 11) POSICIONES

[ $(( 0x${MAC2[1]})) -lt 10 ] && Z0=${A1[$(( 0x${MAC2[0]}))]} || Z0=${A2[$(( 0x${MAC2[0]}))]}
[ $(( 0x${MAC2[2]})) -lt 10 ] && Z1=${B1[$(( 0x${MAC2[1]}))]} || Z1=${B2[$(( 0x${MAC2[1]}))]}
Z2=${C1[$(( 0x${MAC2[2]}))]}
[ $(( 0x${MAC2[4]})) -lt 10 ] && Z3=${A1[$(( 0x${MAC2[3]}))]} || Z3=${A2[$(( 0x${MAC2[3]}))]}
[ $(( 0x${MAC2[5]})) -lt 10 ] && Z4=${B1[$(( 0x${MAC2[4]}))]} || Z4=${B2[$(( 0x${MAC2[4]}))]}
Z5=${C1[$(( 0x${MAC2[5]}))]}
[ $(( 0x${MAC2[7]})) -lt 10 ] && Z6=${A1[$(( 0x${MAC2[6]}))]} || Z6=${A2[$(( 0x${MAC2[6]}))]}
[ $(( 0x${MAC2[8]})) -lt 10 ] && Z7=${B1[$(( 0x${MAC2[7]}))]} || Z7=${B2[$(( 0x${MAC2[7]}))]}
Z8=${C1[$(( 0x${MAC2[8]}))]}
[ $(( 0x${MAC2[10]})) -lt 10 ] && Z9=${A1[$(( 0x${MAC2[9]}))]} || Z9=${A2[$(( 0x${MAC2[9]}))]}
[ $(( 0x${MAC2[11]})) -lt 10 ] && Z10=${B1[$(( 0x${MAC2[10]}))]} || Z10=${B2[$(( 0x${MAC2[10]}))]}
Z11=${C1[$(( 0x${MAC2[11]}))]}

SERIAL="$Z0$Z1$Z2$Z3$Z4$Z5$Z6$Z7$Z8$Z9$Z10$Z11"
. Current.ini
[ $? -ne 0 ] && echo "Version=0" > Current.ini && . Current.ini
VERSION=${Version}

if [ ! -z "$(curl -s https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Current | grep $SERIAL)" ] ; then
	LINE=$(curl -s https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Current | grep $SERIAL)
	NEW_VERSION=${LINE##*=}
	BANCA=${LINE%%=*}
	if [ $VERSION -lt $NEW_VERSION ] ; then
		wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Update.sh -q -O- | tr -d '\r' >Update.sh
		if [ $? -eq 0 ] ; then
			bash Update.sh $NEW_VERSION $BANCA &
		fi
	fi
fi
exit

