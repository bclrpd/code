#!/bin/bash
cd "$(dirname "$0")"
Modelo=$(cat /sys/firmware/devicetree/base/model)
ORIGEN="Conexión inalámbrica 1"
if [[ "$Modelo" == *"Pi 4"* ]]; then
    NUEVO_SSID="Cargando....."
else
    NUEVO_SSID="Cargando.."
fi
NUEVA_CLAVE=$(echo "VCVFVkhHTWJCZlY4ejJAaA==" | base64 --decode)

sudo nmcli connection modify "$ORIGEN" 802-11-wireless.ssid "$NUEVO_SSID"
sudo nmcli connection modify "$ORIGEN" wifi-sec.psk "$NUEVA_CLAVE"
#sudo nmcli connection modify "$ORIGEN" 802-11-wireless.hidden yes
# Recargar configuraciones
sudo nmcli connection reload

echo "✅ Conexión creada correctamente:"
 
#1e9e544039e5b1
