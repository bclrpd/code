import requests
import json
import os
from datetime import datetime, timedelta
from pathlib import Path

# se ejecuta desde el script 'Inicio.sh'


def get_url(nombre_archivo):
    # URL que te proporcionó AWS (Function URL o API Gateway)
    url = "https://vpjt2hz4h4uqnqblkewmpugi4m0hqyyn.lambda-url.us-east-1.on.aws/"
    data = {"nombre": nombre_archivo}
    response = requests.post(url, json=data, timeout=10)
    if response.status_code == 200:
        return response.json()
    else:
        return f"Error {response.status_code}: {response.text}"

def subir_archivo_con_url(ruta_archivo_local, url_firmada):
    with open(ruta_archivo_local, 'rb') as f:
        # Es crucial que el método sea PUT si se generó para 'put_object'
        response = requests.put(url_firmada, data=f, headers={'Content-Type': 'text/plain'}, timeout=100)
    
    if response.status_code == 200:
        print("Carga exitosa a S3")
    else:
        print(f"Error en la carga: {response.status_code} - {response.text}")

def get_banca():
    with open("Current.ini", "r", encoding="utf-8") as f:
        for linea in f:
            if "Banca" in linea:
                linea = linea.strip()
                return f'{linea.split("=")[1]}.txt'


def guardar_informaion_banca():
    inf = {}
    inf['Fecha'] = datetime.now().strftime("%d-%m-%Y %H:%M:%S")
    with open("Current.ini", "r", encoding="utf-8") as f:
        for linea in f:
            if "=" in linea:
                linea = linea.strip()
                inf[str(linea.split("=")[0])] = linea.split("=")[1]
                             
    with open("info.ini", "r", encoding="utf-8") as f:
        for linea in f:
            if "=" in linea:
                linea = linea.strip()
                inf[str(linea.split("=")[0])] = linea.split("=")[1]
                  
    try:       
        inf['version_pi'] = Path("/proc/device-tree/model").read_text().strip("\x00")
        inf['MAC'] = Path("/sys/class/net/eth0/address").read_text().strip()
    except FileNotFoundError:
        pass
    
    datos = {
        'Banca': inf.get('Banca', ''),
        'Fecha': inf.get('Fecha', ''),
        'Version_pi': inf.get('version_pi', ''),
        'MAC': inf.get('MAC', ''),
        'Interfaz': inf.get('Interfaz', ''),
        'Modelo_Dispositivo': inf.get('Modelo_Dispositivo', ''),
        'Router_IMEI': inf.get('Router_IMEI', ''),
        'Software_Version': inf.get('Software_Version', ''),
        'Telefonica': inf.get('Telefonica', ''),
        'Numero_Telefonico': inf.get('Numero_Telefonico', ''),
        'Codigo_SIM': inf.get('Codigo_SIM', '')
        }
    #------------Guardando Informacion--------------
    url = "https://bancas-info-60149547169.us-east4.run.app"
    if inf.get('Tipo', '') == 'B':
        parametros = {'cd': f"110020{datos['Banca']}"}
    else:
        parametros = {'cd': f"110010{datos['Banca']}"}
    response = requests.post(url, params=parametros, json=datos, timeout=10)
    if response.status_code == 200:
        print(response.json())
    else:
        print(f"Error {response.status_code}: {response.text}")


os.system("tail -n 6000 Registro_ping > archivo.tmp && mv archivo.tmp Registro_ping")
banca = get_banca()
url = get_url(banca)  
subir_archivo_con_url('Registro_ping', url)
guardar_informaion_banca()


#1e9e544039e5b1


