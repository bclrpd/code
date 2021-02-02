
#!/bin/bash
cd "$(dirname "$0")"
echo "Version=$1" > Current.ini && echo "Banca=$2" >> Current.ini && rm Update.sh
exit
