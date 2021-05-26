#! /bin/bash
cd "$(dirname "$0")"

until ping -nq -c3 8.8.8.8; do
	sleep 1
done

pip3 install selenium

wget -c https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/chromedriver.tar.xz --limit-rate=50k

if [ "$(md5sum chromedriver.tar.xz | awk 'NR==1 {print $1}')" != "14c68db7dbe360bad84f21c7b8cae255" ]; then
	rm chromedriver.tar.xz
	wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/chromedriver.tar.xz --limit-rate=50k
else
	if [ "$(md5sum chromedriver | awk 'NR==1 {print $1}')" != "2a4815a798c3d44a3ea424b0c82ba248" ]; then
		rm chromedriver
		tar -xf chromedriver.tar.xz chromedriver
	else
		echo "OK"
	fi
fi
exit
