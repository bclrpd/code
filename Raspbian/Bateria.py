import asyncio
import sys
import time
import csv
from datetime import datetime, timedelta
import requests
import json
from bleak import BleakClient, BleakScanner


BATERIAS_WECO = ["WK4S100AH", "WK100AH"]
BATERIAS_WLTRATON = ["DP04S"]

def bateria_weco(device):
    CHAR_UUID = "0000ffe1-0000-1000-8000-00805f9b34fb"
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


    async def get_status(device):
        global response_queue
        response_queue = asyncio.Queue()
        try:
            if device.name and any(item in device.name for item in BATERIAS_WECO):
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

    async def get_historial(device): 
        global ult_ejec_historial
        global response_queue
        response_queue = asyncio.Queue()

        if device.name and any(item in device.name for item in BATERIAS_WECO):
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

    
    global primera_ejecucion
    global ult_ejec_historial
    global intervalo
    estado = asyncio.run(get_status(device))
    if estado:
        if primera_ejecucion:
            print('buscando Historial')
            asyncio.run(get_historial(device))
            primera_ejecucion = False
        elif abs(estado[4]) > 1:
            if ult_ejec_historial < (datetime.now() - timedelta(minutes=15)):
                print('buscando Historial')
                asyncio.run(get_historial(device))
            intervalo = 300
        else:
            print("corriente menor a 1A")
            intervalo = 600
    else:
        intervalo = 300
        
def bateria_wltraton(device):
    # --- CONFIGURACIÓN ---

    UUID_NOTIFICACION = "0000ff01-0000-1000-8000-00805f9b34fb"
    UUID_ESCRITURA    = "0000ff02-0000-1000-8000-00805f9b34fb"

    # Comandos JBD
    COMANDO_INFO_BASICA = b'\xDD\xA5\x03\x00\xFF\xFD\x77'
    COMANDO_CELDAS      = b'\xDD\xA5\x04\x00\xFF\xFC\x77'

    global bms_buffer
    bms_buffer = bytearray()
    respuesta_completada = asyncio.Event()

    # Mapeo de bits para los dos bytes de protección/alertas del JBD
    MAPEO_PROTECCIONES = {
        0: "Sobrevoltaje en Banco (OVP)",
        1: "Bajo Voltaje en Banco (UVP)",
        2: "Sobrevoltaje en Celda (Cell OVP)",
        3: "Bajo Voltaje en Celda (Cell UVP)",
        4: "Sobretemperatura en Carga (OTC)",
        5: "Bajo Temperatura en Carga (UTC)",
        6: "Sobretemperatura en Descarga (OTD)",
        7: "Bajo Temperatura en Descarga (UTD)",
        8: "Sobrecorriente en Carga (OCP)",
        9: "Sobrecorriente en Descarga (OCD)",
        10: "Cortocircuito (Short Circuit)",
        11: "Error en IC Front-End (IC Error)",
        12: "Bloqueo de Software MOS",
    }

    def manejar_notificacion(sender, data):
        #global bms_buffer
        bms_buffer.extend(data)
        if len(bms_buffer) >= 7 and bms_buffer[-1] == 0x77:
            respuesta_completada.set()

    def procesar_info(inf_basica, inf_celdas):
        """Procesa el comando 0x03: Extrae MOSFETs, Ciclos y Alertas de Protección."""
        if len(inf_basica) < 7 or inf_basica[0] != 0xDD or inf_basica[2] != 0x00:
            return
        
        longitud = inf_basica[3]
        datos = inf_basica[4 : 4 + longitud]
        
        voltaje_total = int.from_bytes(datos[0:2], "big") / 100.0
        ciclos = int.from_bytes(datos[8:10], "big")
        # Corriente (en decenas de mA, maneja valores negativos para descarga)
        corriente_raw = int.from_bytes(datos[2:4], "big")
        if corriente_raw & 0x8000: 
            corriente_raw -= 0x10000
        corriente = corriente_raw / 100.0
        
        # Capacidades (en Ah)
        capacidad_restante = int.from_bytes(datos[4:6], "big") / 100.0
        capacidad_nominal = int.from_bytes(datos[6:8], "big") / 100.0
        porcentaje_carga = datos[19] # Estado de Carga (SOC %)
        temp = (int.from_bytes(datos[23:25], "big") - 2731.5 )/ 10.0 #(Convierte Kelvin*10 a Celsius)

        # Estado de los MOSFETs (Byte 20), Bit 0: Carga, Bit 1: Descarga
        mosfet_byte = datos[20]
        carga_activa = bool(mosfet_byte & 0x01)
        descarga_activa = bool(mosfet_byte & 0x02)
        mosfet_carga = 'on' if carga_activa else 'off'
        mosfet_descarga = 'on' if descarga_activa else 'off'
        
        # Estado de Protecciones (Bytes 16 y 17)
        prot_bits = int.from_bytes(datos[16:18], "big")
        alertas_activas = []
        for bit, descripcion in MAPEO_PROTECCIONES.items():
            if prot_bits & (1 << bit):
                alertas_activas.append(descripcion)
                
        if alertas_activas:
            print("\n[🚨] ¡ALERTAS DE PROTECCIÓN ACTIVAS!:")
            for alerta in alertas_activas:
                print(f"   -> {alerta}")
        else:
            print("\n[✅] Estado de seguridad: OK (Sin alertas)")

        """Procesa el comando 0x04: Extrae el voltaje exacto de cada celda."""
        if len(inf_celdas) < 7 or inf_celdas[0] != 0xDD or inf_celdas[2] != 0x00:
            print("Error al leer los datos de las celdas.")
            return
       
        longitud = inf_celdas[3]
        datos = inf_celdas[4 : 4 + longitud]
        
        # Cada celda ocupa 2 bytes (en mV)
        num_celdas = longitud // 2
        voltajes = []
        
        for i in range(num_celdas):
            idx = i * 2
            mv = int.from_bytes(datos[idx:idx+2], "big")
            voltajes.append(mv / 1000.0) # Convertir a Voltios
            
        # Calcular la diferencia (Desbalanceo)
        max_v = max(voltajes)
        min_v = min(voltajes)
        desbalanceo = (max_v - min_v) * 1000.0 # en mV
        desbalanceo = round(desbalanceo, 2)    
        
        fecha = datetime.now().strftime("%Y%m%d%H%M%S")
        
        return(
            banca,
            fecha,
            id_bateria,
            voltaje_total,
            corriente,
            capacidad_restante,
            porcentaje_carga,
            voltajes[0],
            voltajes[1],
            voltajes[2],
            voltajes[3],
            desbalanceo,
            temp,
            ciclos,
            mosfet_carga,
            mosfet_descarga 
        )
    
    def guardar_estado(datos):
        url = "https://s3cr5kdn23qsjiwiwdx2kqkuse0jslvg.lambda-url.us-east-1.on.aws/"
        parametros = {'orden': 'guardar_estado', 'bateria_name': 'wltraton'}
        response = requests.post(url, params=parametros, json=datos, timeout=10)
        if response.status_code == 200:
            print(response.json())
        else:
            print(f"Error {response.status_code}: {response.text}")
    
    async def enviar_y_esperar_comando(client, comando, timeout=4.0):
        """Limpia variables, envía el comando mediante write-without-response y aguarda."""
        #global bms_buffer
        bms_buffer.clear()
        respuesta_completada.clear()
        
        await client.write_gatt_char(UUID_ESCRITURA, comando, response=False)
        await asyncio.wait_for(respuesta_completada.wait(), timeout=timeout)
        return list(bms_buffer)
            
    async def main():
        for device in devices:
            if device.name and any(item in device.name for item in BATERIAS_WLTRATON):
                print(f"\nConectando a {device.name}...\n")
                async with BleakClient(device.address) as client:
                    if client.is_connected:
                        print("Conectado\n")
                        await client.start_notify(UUID_NOTIFICACION, manejar_notificacion)
                        await asyncio.sleep(0.5)
                        global id_bateria
                        id_bateria = client.name
                        try:
                            inf_basica = await enviar_y_esperar_comando(client, COMANDO_INFO_BASICA)
                            await asyncio.sleep(0.3)
                            inf_celdas = await enviar_y_esperar_comando(client, COMANDO_CELDAS)
                            estado = procesar_info(inf_basica,inf_celdas)
                            print(estado)
                            guardar_estado(estado)
                            
                            global intervalo
                            if abs(estado[4]) > 1:
                                intervalo = 10
                            else:
                                intervalo = 20
                        except asyncio.TimeoutError:
                            print("Error: El BMS no respondió a uno de los comandos a tiempo.")
                        finally:
                            await client.stop_notify(UUID_NOTIFICACION)
                    else:
                        print("No se pudo conectar al dispositivo.")                                        
        
    
    asyncio.run(main())



async def escanear():
    try:
        print("Buscando Bateria...")
        devices = await BleakScanner.discover(timeout=10.0)
        return devices
    except Exception as e:
        return None

try:
    banca = sys.argv[1]
except Exception as e:
    banca = 00

primera_ejecucion = True
ult_ejec_historial = datetime.now() - timedelta(days=1)
intentos = -10
intervalo = 5

if __name__ == "__main__":    
    while intentos < 5:
        intervalo = 27 #intervalo default 27s
        try:
            bateria_detectada = False
            devices = asyncio.run(escanear())
            for device in devices:
                if device.name:
                    if any(item in device.name for item in BATERIAS_WECO):
                        bateria_weco(device)
                        bateria_detectada = True
                    elif any(item in device.name for item in BATERIAS_WLTRATON):
                        bateria_wltraton(device)
                        bateria_detectada = True
                        
            if bateria_detectada:
                intentos = -10
            else:
                intentos = intentos + 1           
                           
        except Exception as e:
            intentos = intentos + 1
            print(e)
        print(f"esperando por {intervalo}s")
        time.sleep(intervalo)


#1e9e544039e5b1
