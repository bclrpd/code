#!/bin/bash
SHUTDOWN=$(zenity --info --title="Shutdown Options" --timeout=30 --no-wrap --text="Reiniciar o Apagar ?" --icon-name=system-shutdown --ok-label="Cancelar" --extra-button="Reiniciar" --extra-button="Apagar")

if [ "$SHUTDOWN" == "Reiniciar" ]; then
    systemctl reboot -i
elif [ "$SHUTDOWN" == "Apagar" ]; then
    systemctl poweroff -i
fi
exit 0

