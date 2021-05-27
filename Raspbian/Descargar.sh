#! /bin/bash
cd "$(dirname "$0")"

until ping -nq -c3 8.8.8.8; do
	sleep 1
done
if [ "$(pip3 list | grep selenium -w | awk '{print $1}')" != "selenium" ]; then

	wget -c https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/selenium-3.141.0.tar.gz --limit-rate=10k
	if [ "$(md5sum selenium-3.141.0.tar.gz | awk 'NR==1 {print $1}')" != "063be08e0f71396a5dd20c9f9ca099dd" ]; then
		pip3 install selenium-3.141.0.tar.gz
	else
		rm selenium-3.141.0.tar.gz
		wget -c https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/selenium-3.141.0.tar.gz --limit-rate=5k
	fi
else
	echo "OK"
fi 


wget -c https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/chromedriver.tar.xz --limit-rate=10k

if [ "$(md5sum chromedriver.tar.xz | awk 'NR==1 {print $1}')" != "14c68db7dbe360bad84f21c7b8cae255" ]; then
	rm chromedriver.tar.xz
	wget https://raw.githubusercontent.com/bclrpd/code/main/Raspbian/chromedriver.tar.xz --limit-rate=5k
else
	if [ "$(md5sum chromedriver | awk 'NR==1 {print $1}')" != "2a4815a798c3d44a3ea424b0c82ba248" ]; then
		rm chromedriver
		tar -xf chromedriver.tar.xz chromedriver
		chmod +rwx chromedriver
		chmod +rwx chromium-browser
	else
		echo "OK"
	fi
fi
exit
