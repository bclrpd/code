#!/bin/bash
cd "$(dirname "$0")"
ORIGEN="Conexión inalámbrica 1"
DESTINO="Conexión inalámbrica 2"

NUEVO_SSID="Cargando.."
NUEVA_CLAVE=$(echo "VCVFVkhHTWJCZlY4ejJAaA==" | base64 --decode)

if ! nmcli connection show "$ORIGEN" >/dev/null 2>&1; then
    echo "❌ La conexión origen no existe: $ORIGEN"
    exit 1
fi

if nmcli connection show "$DESTINO" >/dev/null 2>&1; then
    echo "⚠️ La conexión destino ya existe. Eliminando..."
    sudo nmcli connection delete "$DESTINO"
fi

sudo nmcli connection clone "$ORIGEN" "$DESTINO"
sudo nmcli connection modify "$DESTINO" 802-11-wireless.ssid "$NUEVO_SSID"
sudo nmcli connection modify "$DESTINO" wifi-sec.psk "$NUEVA_CLAVE"
sudo nmcli connection modify "$DESTINO" connection.autoconnect yes
sudo nmcli connection modify "$DESTINO" connection.permissions "user:ventas"

# Recargar configuraciones
sudo nmcli connection reload

echo "✅ Conexión creada correctamente:"
 
#1e9e544039e5b1
