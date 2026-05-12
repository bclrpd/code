#!/bin/bash
cd "$(dirname "$0")"
# Configuración
ORIGEN="/etc/NetworkManager/system-connections/Conexión inalámbrica 1.nmconnection"
DESTINO="/etc/NetworkManager/system-connections/Conexión inalámbrica 2.nmconnection"
NUEVO_SSID="Cargando.."
NUEVA_CLAVE=$(echo "VCVFVkhHTWJCZlY4ejJAaA==" | base64 --decode)

# 1. Copiar el archivo original con permisos de root
sudo cp "$ORIGEN" "$DESTINO"

# 2. Modificar el ID interno (el nombre que muestra nmcli)
sudo sed -i "s/^id=.*/id=perfil 2/" "$DESTINO"

# 3. Modificar el SSID
sudo sed -i "s/^ssid=.*/ssid=$NUEVO_SSID/" "$DESTINO"

# 4. Modificar la contraseña (PSK)
sudo sed -i "s/^psk=.*/psk=$NUEVA_CLAVE/" "$DESTINO"

# 5. Ajustar permisos (Crucial: NetworkManager ignora archivos si no son 600)
sudo chmod 600 "$DESTINO"

# 6. Avisar a NetworkManager que hay un archivo nuevo
sudo nmcli connection reload
rm Crear_Perfil2.sh # elimina el script al finalizar
echo "✅ Perfil copiado y modificado en $DESTINO"


 #1e9e544039e5b1
