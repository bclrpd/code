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

# Convertimos bateria_weco en async def
async def bateria_weco(device):
    CHAR_UUID = "0000ffe1-0000-1000-8000-00805f9b34fb"
    CMD_INFO = bytes.fromhex("0b030040f0f3")
    CMD_STATUS = bytes.fromhex("0b03014060f2")

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
        
    def signed16_status(value):
        if value > 0x7FFF:
            return value - 0x10000
        return value

    def signed16_historial(value):
        if value > 0x7FFFFFFF:
            return value - 0x100000000
        return value    
          
    def crrear_cmd_historial(index):
        payload = bytes([0x0B, 0x03, 0x05, 0x01, (index >> 8) & 0xFF, index & 0xFF])
        crc = crc16_modbus(payload)
        return payload + bytes([(crc >> 8) & 0xFF, crc & 0xFF])
        
    def notification_handler(sender, data):
        if response_queue is not None:
            response_queue.put_nowait(bytes(data))

    async def enviar_commando(client, command):
        await client.write_gatt_char(CHAR_UUID, command, response=True)
        await asyncio.sleep(0.2)
        try:
            return await asyncio.wait_for(response_queue.get(), timeout=5)
        except asyncio.TimeoutError:
            return None
     
    def decodificar_status(data):
        corriente_raw = int.from_bytes(data[4:6], "big")
        corriente = signed16_status(corriente_raw) / 100.0
        cells = [int.from_bytes(data[pos:pos + 2], "big") / 1000.0 for pos in range(6, 14, 2)]
        pack_voltage = int.from_bytes(data[38:40], "big") / 100.0
        temps = [int.from_bytes(data[pos:pos + 2], "big") / 100.0 for pos in range(40, 48, 2)]
        resistencia = int.from_bytes(data[56:58], "big") / 1000.0   
        ciclos = int.from_bytes(data[60:62], "big")       
        fecha = datetime.now().strftime("%Y%m%d%H%M%S")
        
        return (banca, fecha, id_bateria, pack_voltage, corriente, cells[0], cells[1], cells[2], cells[3], temps[0], temps[1], temps[2], temps[3], resistencia, ciclos)

    def decodificar_historial(data):
        cells = [int.from_bytes(data[pos:pos+2], "big") / 1000 for pos in range(4, 12, 2)]
        pack_voltage = int.from_bytes(data[36:38], "big") / 100
        temps = [int.from_bytes(data[pos:pos+2], "big") / 100 for pos in range(38, 46, 2)]
        fecha = datetime.fromtimestamp(int.from_bytes(data[58:62], "big")).strftime("%Y%m%d%H%M%S")
        corriente = signed16_historial(int.from_bytes(data[0:4], "big")) / 1000
        return (banca, fecha, id_bateria, pack_voltage, corriente, cells[0], cells[1], cells[2], cells[3], temps[0], temps[1], temps[2], temps[3])

    def extraer_info_historial(data):
        records = []
        if len(data) < 130: return records
        records.append(decodificar_historial(data[4:68]))
        records.append(decodificar_historial(data[68:132]))
        return records

    def guardar_historial(datos):
        url = "https://s3cr5kdn23qsjiwiwdx2kqkuse0jslvg.lambda-url.us-east-1.on.aws/"
        response = requests.post(url, params={'orden': 'guardar_historial'}, json=datos, timeout=10)
        if response.status_code == 200:
            print(response.json())
        else:
            print(f"Error {response.status_code}: {response.text}")    
    def guardar_estado(datos):
        url = "https://s3cr5kdn23qsjiwiwdx2kqkuse0jslvg.lambda-url.us-east-1.on.aws/"
        response = requests.post(url, params={'orden': 'guardar_estado', 'bateria_name': 'weco'}, json=datos, timeout=10)
        if response.status_code == 200:
            print(response.json())
        else:
            print(f"Error {response.status_code}: {response.text}")
      
    def calcular_cantidad_registros(bateria_id):
        url = "https://s3cr5kdn23qsjiwiwdx2kqkuse0jslvg.lambda-url.us-east-1.on.aws/"
        try:
            response = requests.post(url, params={'orden': 'ultiomo_registro', 'bateria_id': bateria_id}, timeout=10)
            if response.status_code == 200:
                dato = response.json()
                if not dato: return {'total': 144}
                fecha = datetime.strptime(dato['Fecha'], "%Y%m%d%H%M%S")
                total = ((datetime.now() - fecha).total_seconds() / 60 / 10) + 2
                return {'total': int(min(total, 144)), 'fecha': fecha}
        except Exception:
            pass
        return {'total': 144, 'fecha': datetime.now() - timedelta(days=2)}

    async def get_status(device):
        global response_queue, id_bateria
        response_queue = asyncio.Queue()
        try:
            if device.name and any(item in device.name for item in BATERIAS_WECO):
                id_bateria = device.name
                print(f"\nConectando a {device.name}...\n")
                async with BleakClient(device) as client:
                    await client.start_notify(CHAR_UUID, notification_handler)
                    await asyncio.sleep(0.2)
                    status = await enviar_commando(client, CMD_STATUS)
                    if status:
                        estado = decodificar_status(status)
                        guardar_estado(estado)
                        return estado
            return None
        except Exception:
            return None

    async def get_historial(device): 
        global ult_ejec_historial, response_queue, id_bateria
        response_queue = asyncio.Queue()

        if device.name and any(item in device.name for item in BATERIAS_WECO):
            informacion = []
            id_bateria = device.name
            async with BleakClient(device) as client:
                await client.start_notify(CHAR_UUID, notification_handler)
                x = calcular_cantidad_registros(id_bateria)
                if x.get('total', ''):
                    for index in range(1, x.get('total'), 2):
                        cmd = crrear_cmd_historial(index)
                        try:
                            data = await enviar_commando(client, cmd)
                            if not data or len(data) < 50: break
                            informacion.extend(extraer_info_historial(data))
                        except Exception:
                            pass
                    f = x.get('fecha').strftime("%Y%m%d%H%M%S")
                    datos_filtrados = [item for item in informacion if int(item[1]) >= int(f)]
                    guardar_historial(datos_filtrados)
            ult_ejec_historial = datetime.now()

    global primera_ejecucion, ult_ejec_historial, intervalo
    
    # CAMBIO AQUÍ: Usamos await en lugar de asyncio.run()
    estado = await get_status(device)
    if estado:
        if primera_ejecucion:
            print('buscando Historial')
            await get_historial(device)
            primera_ejecucion = False
        elif abs(estado[4]) > 1:
            if ult_ejec_historial < (datetime.now() - timedelta(minutes=15)):
                print('buscando Historial')
                await get_historial(device)
            intervalo = 300
        else:
            intervalo = 600
        intervalo = 300
        
# Convertimos bateria_wltraton en async def
async def bateria_wltraton(device):
    UUID_NOTIFICACION = "0000ff01-0000-1000-8000-00805f9b34fb"
    UUID_ESCRITURA    = "0000ff02-0000-1000-8000-00805f9b34fb"
    COMANDO_INFO_BASICA = b'\xDD\xA5\x03\x00\xFF\xFD\x77'
    COMANDO_CELDAS      = b'\xDD\xA5\x04\x00\xFF\xFC\x77'

    global bms_buffer
    bms_buffer = bytearray()
    respuesta_completada = asyncio.Event()

    def manejar_notificacion(sender, data):
        bms_buffer.extend(data)
        if len(bms_buffer) >= 7 and bms_buffer[-1] == 0x77:
            respuesta_completada.set()

    def procesar_info(inf_basica, inf_celdas):
        if len(inf_basica) < 7 or inf_basica[0] != 0xDD or inf_basica[2] != 0x00: return
        datos = inf_basica[4 : 4 + inf_basica[3]]
        voltaje_total = int.from_bytes(datos[0:2], "big") / 100.0
        ciclos = int.from_bytes(datos[8:10], "big")
        corriente_raw = int.from_bytes(datos[2:4], "big")
        if corriente_raw & 0x8000: corriente_raw -= 0x10000
        corriente = corriente_raw / 100.0
        capacidad_restante = int.from_bytes(datos[4:6], "big") / 100.0
        porcentaje_carga = datos[19]
        temp = (int.from_bytes(datos[23:25], "big") - 2731.5 )/ 10.0
        mosfet_carga = 'on' if bool(datos[20] & 0x01) else 'off'
        mosfet_descarga = 'on' if bool(datos[20] & 0x02) else 'off'

        datos_c = inf_celdas[4 : 4 + inf_celdas[3]]
        num_celdas = inf_celdas[3] // 2
        voltajes = [int.from_bytes(datos_c[i*2 : i*2+2], "big") / 1000.0 for i in range(num_celdas)]
        desbalanceo = round((max(voltajes) - min(voltajes)) * 1000.0, 2)    
        fecha = datetime.now().strftime("%Y%m%d%H%M%S")
        
        return(banca, fecha, id_bateria, voltaje_total, corriente, capacidad_restante, porcentaje_carga, voltajes[0], voltajes[1], voltajes[2], voltajes[3], desbalanceo, temp, ciclos, mosfet_carga, mosfet_descarga)
    
    def guardar_estado(datos):
        url = "https://s3cr5kdn23qsjiwiwdx2kqkuse0jslvg.lambda-url.us-east-1.on.aws/"
        response = requests.post(url, params={'orden': 'guardar_estado', 'bateria_name': 'wltraton'}, json=datos, timeout=10)
        if response.status_code == 200:
            print(response.json())
        else:
            print(f"Error {response.status_code}: {response.text}")
            
    async def enviar_y_esperar_comando(client, comando, timeout=4.0):
        bms_buffer.clear()
        respuesta_completada.clear()
        await client.write_gatt_char(UUID_ESCRITURA, comando, response=False)
        await asyncio.sleep(0.1)
        await asyncio.wait_for(respuesta_completada.wait(), timeout=timeout)
        return list(bms_buffer)

    print(f"\nConectando a {device.name}...\n")
    async with BleakClient(device) as client:
        if client.is_connected:
            await client.start_notify(UUID_NOTIFICACION, manejar_notificacion)
            await asyncio.sleep(0.5)
            global id_bateria, intervalo
            id_bateria = device.name
            try:
                inf_basica = await enviar_y_esperar_comando(client, COMANDO_INFO_BASICA)
                await asyncio.sleep(0.3)
                inf_celdas = await enviar_y_esperar_comando(client, COMANDO_CELDAS)
                estado = procesar_info(inf_basica, inf_celdas)
                guardar_estado(estado)
                intervalo = 300 if abs(estado[4]) > 1 else 600
            except asyncio.TimeoutError:
                print("Error: El BMS no respondió a tiempo.")
            finally:
                await client.stop_notify(UUID_NOTIFICACION)
                await asyncio.sleep(0.2)

# Función principal que controlará el bucle infinito de forma asíncrona
async def main_loop():
    global intervalo
    intentos = -10
    while intentos < 5:
        intervalo = 27
        try:
            print("Buscando Bateria...")
            devices = await BleakScanner.discover(timeout=10.0)
            bateria_detectada = False
            
            for device in devices:
                if device.name:
                    if any(item in device.name for item in BATERIAS_WECO):
                        await bateria_weco(device) # Await directo
                        bateria_detectada = True
                    elif any(item in device.name for item in BATERIAS_WLTRATON):
                        await bateria_wltraton(device) # Await directo
                        bateria_detectada = True
                        
            if bateria_detectada:
                intentos = -10
            else:
                intentos += 1           
                           
        except Exception as e:
            intentos += 1
            print(f"Error en loop: {e}")
            
        print(f"esperando por {intervalo}s")
        await asyncio.sleep(intervalo) # IMPORTANTE: usar asyncio.sleep en lugar de time.sleep

try:
    banca = sys.argv[1]
except Exception:
    banca = 99

primera_ejecucion = True
ult_ejec_historial = datetime.now() - timedelta(days=1)
intervalo = 5

if __name__ == "__main__":    
    # UNICO punto de arranque del loop de asyncio
    asyncio.run(main_loop())

#1e9e544039e5b1
