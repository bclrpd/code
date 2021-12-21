#! /bin/bash
cd "$(dirname "$0")"
wget -c https://raw.githubusercontent.com/bclrpd/code/main/Rifa.jpg
[ $? -eq 0 ] && pcmanfm --set-wallpaper "/home/ventas/.Auto/Rifa.jpg"
exit
