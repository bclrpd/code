import asyncio
import sys
import time
import csv
from datetime import datetime, timedelta
import requests
import json
from bleak import BleakClient, BleakScanner

CHAR_UUID = "0000ffe1-0000-1000-8000-00805f9b34fb"
DEVICE_NAME = ["WK4S100AH", "WK100AH"]

CMD_INFO = bytes.fromhex("0b030040f0f3")
CMD_STATUS = bytes.fromhex("0b03014060f2")

# ----------------------------------------------------
# CRC16 MODBUS
# ----------------------------------------------------

def crc16_modbus(data):
    crc = 0xFFFF
    for b in data:
        crc ^= b
        for _ in range(8):
            if crc & 1:
                crc = (crc >> 1) ^ 0xA001
            else:
                crc >>= 1
    return crc
    
def signed16_status(value): #funcion para asignarle un signo a la corriente
    if value > 0x7FFF:
        return value - 0x10000
    return value

def signed16_historial(value):  #funcion para asignarle un signo a la corriente
    if value > 0x7FFFFFFF:
        return value - 0x100000000
    return value    
      
def crrear_cmd_historial(index):
    payload = bytes([
        0x0B,
        0x03,
        0x05,
        0x01,  #cambiar a 0x02 para el historiar de errores
        (index >> 8) & 0xFF,
        index & 0xFF
    ])
    crc = crc16_modbus(payload)
    return payload + bytes([
        (crc >> 8) & 0xFF,
        crc & 0xFF       
    ])
    

def notification_handler(sender, data):
    if response_queue is not None:
        response_queue.put_nowait(bytes(data))


# ----------------------------------------------------
# ENVIO COMANDO
# ----------------------------------------------------
async def enviar_commando(client, command):
    await client.write_gatt_char(CHAR_UUID, command, response=True)
    try:
        return await asyncio.wait_for(response_queue.get(), timeout=5)
    except asyncio.TimeoutError:
        return None
 
def decodificar_status(data):
    # Corriente
    corriente_raw = int.from_bytes(data[4:6], "big")
    corriente = signed16_status(corriente_raw) / 100.0

    # Voltajes de celdas
    cells = []
    pos = 6
    for _ in range(4):
        mv = int.from_bytes(data[pos:pos + 2], "big")
        cells.append(mv / 1000.0)
        pos += 2

    # Voltaje pack
    pack_voltage = int.from_bytes(data[38:40], "big") / 100.0

    # Temperaturas
    temps = []
    pos = 40
    for _ in range(4):
        t = int.from_bytes(data[pos:pos + 2], "big")
        temps.append(t / 100.0)
        pos += 2

    # Resistencia interna
    resistencia = int.from_bytes(data[56:58], "big") / 1000.0   
    ciclos = int.from_bytes(data[60:62], "big")       
    #fecha = int.from_bytes(data[64:68], "big")
    #fecha = datetime.fromtimestamp(fecha).strftime("%Y%m%d%H%M%S")
    fecha = datetime.now().strftime("%Y%m%d%H%M%S")
    
    return (
        banca,
        fecha,
        id_bateria,
        pack_voltage,
        corriente,
        cells[0],
        cells[1],
        cells[2],
        cells[3],
        temps[0],
        temps[1],
        temps[2],
        temps[3],
        resistencia,
        ciclos
    )
    
    
    return {
        "corriente": corriente,
        "pack_voltage": pack_voltage,
        "cells": cells,
        "temps": temps,
        "resistance": resistencia,
        "ciclos": ciclos,
        "fecha": datetime.fromtimestamp(fecha)
    }

def decodificar_historial(data):
    cells = []
    pos = 4
    for _ in range(4):
        mv = int.from_bytes(data[pos:pos+2], "big")
        cells.append(mv / 1000)
        pos += 2
    pack_voltage = int.from_bytes(data[36:38], "big") / 100
    temps = []
    pos = 38

    for _ in range(4):
        t = int.from_bytes(data[pos:pos+2], "big")
        temps.append(t / 100)
        pos += 2

    fecha = int.from_bytes(data[58:62], "big")
    fecha = datetime.fromtimestamp(fecha).strftime("%Y%m%d%H%M%S")
    corriente = int.from_bytes(data[0:4], "big") 
    # coorinete positiva o negativa
    corriente = signed16_historial(corriente) / 1000
    return (
        banca,
        fecha,
        id_bateria,
        pack_voltage,
        corriente,
        cells[0],
        cells[1],
        cells[2],
        cells[3],
        temps[0],
        temps[1],
        temps[2],
        temps[3]
    )

def extraer_info_historial(data):
    records = []
    if len(data) < 130:
        return records
    r1 = data[4:68]
    r2 = data[68:132]
    records.append(decodificar_historial(r1))
    records.append(decodificar_historial(r2))
    return records


def guardar_historial(datos):
    url = "https://s3cr5kdn23qsjiwiwdx2kqkuse0jslvg.lambda-url.us-east-1.on.aws/"
    parametros = {'orden': 'guardar_historial'}
    response = requests.post(url, params=parametros, json=datos, timeout=10)
    if response.status_code == 200:
        print(response.json())
    else:
        print(f"Error {response.status_code}: {response.text}")
        
def guardar_estado(datos):
    url = "https://s3cr5kdn23qsjiwiwdx2kqkuse0jslvg.lambda-url.us-east-1.on.aws/"
    parametros = {'orden': 'guardar_estado'}
    response = requests.post(url, params=parametros, json=datos, timeout=10)
    if response.status_code == 200:
        print(response.json())
    else:
        print(f"Error {response.status_code}: {response.text}")
  
def calcular_cantidad_registros(bateria_id):
    url = "https://s3cr5kdn23qsjiwiwdx2kqkuse0jslvg.lambda-url.us-east-1.on.aws/"
    parametros = {'orden': 'ultiomo_registro', 'bateria_id': bateria_id}
    try:
        response = requests.post(url, params=parametros, timeout=10)
        if response.status_code == 200:
            dato = response.json()
            if not dato:
                return {'total': 144}  #cuando la bateria no esta en la base de datos
            
            fecha = dato['Fecha']
            fecha = datetime.strptime(fecha, "%Y%m%d%H%M%S")
            ahora = datetime.now()
            diferencia = (ahora - fecha).total_seconds() / 60
            total = diferencia / 10
            total = total + 2  # para incluir los ultimos 2 registros que se almacenaron
            if total > 144:
                total = 144
            return {'total': int(total), 'fecha': fecha}

        else:
            print(f"Error {response.status_code}: {response.text}")
            return None
    except Exception as e:
        print("Error:")
    
    return None

async def buscar_baterias():
    try:
        print("Buscando Bateria...")
        devices = await BleakScanner.discover(timeout=10.0)
        for device in devices:
            if device.name and any(item in device.name for item in DEVICE_NAME):
                return devices
        return None
    except Exception as e:
        return None

async def get_status(devices):
    global response_queue
    response_queue = asyncio.Queue()
    try:
        for device in devices:
            if device.name and any(item in device.name for item in DEVICE_NAME):
                global id_bateria
                id_bateria = device.name
                print(f"\nConectando a {device.name}...\n")
                async with BleakClient(device.address) as client:
                    await client.start_notify(CHAR_UUID, notification_handler)
                    print("Conectado\n")
                    status = await enviar_commando(client, CMD_STATUS)
                    if status:
                        estado = decodificar_status(status)
                        guardar_estado(estado)
                        print(estado)
                        print("-" * 60)
                        return estado
                        #await asyncio.sleep(2)
        return None
    except Exception as e:
        return None

async def get_historial(devices): 
    global ult_ejec_historial
    global response_queue
    response_queue = asyncio.Queue()
    
    for device in devices:
        if device.name and any(item in device.name for item in DEVICE_NAME):
            informacion = []
            global id_bateria
            id_bateria = device.name
            
            print(f"\nConectando a {id_bateria}...")
            async with BleakClient(device.address) as client:
                await client.start_notify(CHAR_UUID, notification_handler)
                print("Conectado")
                
                x = calcular_cantidad_registros(id_bateria)
                if x.get('total', ''):
                    for index in range(1, x.get('total'), 2):
                        cmd = crrear_cmd_historial(index)
                        try:
                            data = await enviar_commando(client, cmd)
                            if len(data) < 50:
                                break
                            info = extraer_info_historial(data)
                            informacion.extend(info)
                        except Exception as e:
                            print("Error:", index, e)
                    
                    f = x.get('fecha', (datetime.now() - timedelta(days=2))).strftime("%Y%m%d%H%M%S")
                    datos_filtrados = [item for item in informacion if int(item[1]) >= int(f)]
                    print(f"Registros obtenidos: {len(datos_filtrados)}")  
            guardar_historial(datos_filtrados)
            ult_ejec_historial = datetime.now()




try:
    banca = sys.argv[1]
except Exception as e:
    banca = 00
intentos = 0
ult_ejec_historial = datetime.now() - timedelta(days=1)

if __name__ == "__main__":    
    while intentos < 5:
        devices = asyncio.run(buscar_baterias())
        if devices:
            estado = asyncio.run(get_status(devices))
            if estado:
                if abs(estado[4]) > 1:
                    if ult_ejec_historial < (datetime.now() - timedelta(minutes=15)):
                        print('buscando Historial')
                        asyncio.run(get_historial(devices))
                    time.sleep(300)
                else:
                    print("corriente menor a 1A")
                    time.sleep(600)
            else:
                time.sleep(300)
                
                
            intentos = -5
        else:
            intentos = intentos + 1
            time.sleep(30)


#1e9e544039e5b1
