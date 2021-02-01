#! /bin/bash


while true ; do

URI=$(lpstat -s |grep "para Impresora" | awk '{print $4}')
NEWURI=$(lpinfo -v |grep "usb" | awk '{print $2}')
echo $URI
echo $NEWURI

if [ ! -z $NEWURI ] ; then

	if [ $NEWURI != $URI ] ; then
		lpadmin -p Impresora -v $NEWURI
		echo "Actualizada"
	fi
	break
fi
sleep 2
done
