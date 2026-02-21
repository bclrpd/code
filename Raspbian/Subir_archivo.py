import requests
import json
import os

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


os.system("tail -n 1000 Registro_ping > archivo.tmp && mv archivo.tmp Registro_ping")
banca = get_banca()
url = get_url(banca)  
subir_archivo_con_url('Registro_ping', url)



