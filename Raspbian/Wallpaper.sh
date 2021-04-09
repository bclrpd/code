#!/bin/bash
until ping -nq -c3 8.8.8.8; do
		sleep 1
done
wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/Wallpaper.jpg -O Wallpaper.jpg
[ $? -eq 0 ] && pcmanfm --set-wallpaper "/home/ventas/.Auto/Wallpaper.jpg"
rm Wallpaper.sh
exit
