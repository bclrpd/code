import os
import re
import json
import requests
from configparser import ConfigParser
from bs4 import BeautifulSoup
from io import StringIO
from datetime import date, datetime, timezone, timedelta
import urllib.parse
import base64
import hashlib
import time
import sys
import xml.etree.ElementTree as ET
import fileinput
import random


headers = {
    "Accept": "application/json, text/plain, */*",
    "Content-Type": "application/json",
    "Origin": 'http://192.168.1.1',
    "Referer": 'http://192.168.1.1/',
    "_TclRequestVerificationKey": 'KSDHSDFOGQ5WERYTUIQWERTYUISDFG1HJZXCVCXBN2GDSMNDHKVKFsVBNf',
    "custom_id": "JO",
    "device_name": "HH63A"
}

payload = {
    "_": int(time.time() * 1000),
    "id": f"{random.uniform(0, 100):.1f}",
    "jsonrpc": "2.0",
    "method": "",
    "params": {}
}


def logear():
    try:
        response = requests.post('http://192.168.1.1/jrd/webapi', json={'method': 'GetDeviceSt',}, verify=False)
        if response.status_code == 200:
            salt_del_router = response.json()['result']['Salt']
            #print(salt_del_router)
            psw = base64.b64decode("VCVFVkhHTWJCZlY4ejJAaA==").decode("utf-8")
            #psw = 'claro1234'
            psw_bytes = psw.encode('utf-8')
            salt_bytes = salt_del_router.encode('utf-8')
            hash_bytes = hashlib.pbkdf2_hmac(
                'sha512', 
                psw_bytes, 
                salt_bytes, 
                1024, 
                64
            )
            psw_encriptado = hash_bytes.hex()
            
            payload["_"] = int(time.time() * 1000)
            payload["id"] = f"{random.uniform(0, 100):.1f}"
            payload["method"] = "Login"
            payload["params"] = {"UserName": "dc13ibej?7", "Password": psw_encriptado}
            
            while True:
                response = requests.post('http://192.168.1.1/jrd/webapi', headers=headers, json=payload, verify=False, timeout=10, allow_redirects=False)
                if response.status_code == 200:
                    token = response.json()['result']['token']
                    headers['_TclRequestVerificationToken'] = token
                    break
                print("Error al Logear")
                time.sleep(2)
    except Exception as e:
        print(f"Error fatal_0: {str(e)}")
     
def aceptar_condiciones():
    try:
        params = {'name': 'SetPrivacySettings',}
        payload["_"] = int(time.time() * 1000)
        payload["id"] = f"{random.uniform(0, 100):.1f}"
        payload["method"] = "SetPrivacySettings"
        payload["params"] = {'PrivacyFlag': 1,}
        response = requests.post('http://192.168.1.1/jrd/webapi', params=params, headers=headers, json=payload, verify=False)
        if response.status_code == 200:
            print(f"Condiciones Aceptadas")
    except Exception as e:
        print(f"Error fatal: {str(e)}")
        return

def cambiar_clave():
    CurrPassword_encriptado = ""
    NewPassword_encriptado = ""
    try:
        response = requests.post('http://192.168.1.1/jrd/webapi', json={'method': 'GetDeviceSt',}, verify=False)
        if response.status_code == 200:
            salt_del_router = response.json()['result']['Salt']
            salt_bytes = salt_del_router.encode('utf-8')
            CurrPassword = 'claro1234'
            CurrPassword_bytes = CurrPassword.encode('utf-8')
            hash_bytes_CurrPassword = hashlib.pbkdf2_hmac(
                'sha512', 
                CurrPassword_bytes, 
                salt_bytes, 
                1024, 
                64
            )
            CurrPassword_encriptado = hash_bytes_CurrPassword.hex()
            NewPassword = base64.b64decode("VCVFVkhHTWJCZlY4ejJAaA==").decode("utf-8")
            NewPassword_bytes = NewPassword.encode('utf-8')
            hash_bytes_NewPassword = hashlib.pbkdf2_hmac(
                'sha512', 
                NewPassword_bytes, 
                salt_bytes, 
                1024, 
                64
            )
            NewPassword_encriptado = hash_bytes_NewPassword.hex()
            print("contrase;as encriptadas")
    except Exception as e:
        print(f"Error fatal_1: {str(e)}")
        return

    try:
        params = {'name': 'ChangePassword',}
        payload["_"] = int(time.time() * 1000)
        payload["id"] = f"{random.uniform(0, 100):.1f}"
        payload["method"] = "ChangePassword"
        payload["params"] = {'UserName': 'dc13ibej?7', 'CurrPassword': CurrPassword_encriptado, 'NewPassword': NewPassword_encriptado,}
        response = requests.post('http://192.168.1.1/jrd/webapi', params=params, headers=headers, json=payload, verify=False)
        if response.status_code == 200:
            print("Contraseña Modificada")
            params = {'name': 'SetPasswordChangeFlag',}
            payload["_"] = int(time.time() * 1000)
            payload["id"] = f"{random.uniform(0, 100):.1f}"
            payload["method"] = "SetPasswordChangeFlag"
            payload["params"] = {'change_flag': 1,}
            response = requests.post('http://192.168.1.1/jrd/webapi', params=params, headers=headers, json=payload, verify=False)
            if response.status_code == 200:
                print("Contraseña Modificada")
        
    except Exception as e:
        print(f"Error fatal_2: {str(e)}")
        return

def configurar_wifi():
    
    try:
        paramsGet = {'name': 'GetWlanSettings',}
        paramsSet = {'name': 'SetWlanSettings',}
        payload["_"] = int(time.time() * 1000)
        payload["id"] = f"{random.uniform(0, 100):.1f}"
        payload["method"] = "GetWlanSettings"
        payload["params"] = {}
        response = requests.post('http://192.168.1.1/jrd/webapi', params=paramsGet, headers=headers, json=payload, verify=False)
        if response.status_code == 200:
            AP2G = response.json()['result']['AP2G']
            AP5G = response.json()['result']['AP5G']
            AP2G_guest = response.json()['result']['AP2G_guest']
            AP5G_guest = response.json()['result']['AP5G_guest'] 
            
            payload['_'] = int(time.time() * 1000)
            payload["id"] = f"{random.uniform(0, 100):.1f}"
            payload["method"] = 'SetWlanSettings'
            payload["params"] = {
                'WiFiState': 0,
                'ApState': 0,
                'preferred': 0,
                'WlanAPMode': 0,
                'selectMode': 1,
                'WiFiOffTime': 0,
                'isolate': 0,
                'SleepMode': 0,
                'AP2G': AP2G,
                'AP5G': AP5G,
                'AP2G_guest': AP2G_guest,
                'AP5G_guest': AP5G_guest,
                }
            
            payload["params"]['AP2G']['Ssid'] = "Cargando.."
            payload["params"]['AP2G']['WpaKey'] = "T%EVHGMbBfV8z2@h"
            payload["params"]['AP2G']['Channel'] = 9
            payload["params"]['AP2G']['Bandwidth'] = 1
            payload["params"]['AP5G']['Ssid'] = "Cargando....."
            payload["params"]['AP5G']['WpaKey'] = "T%EVHGMbBfV8z2@h"
            payload["params"]['AP5G']['Channel'] = 40
            
            print("configurando WIFI, si todo sale bien la señal wifi deberia reiniciarse  ")
            response = requests.post('http://192.168.1.1/jrd/webapi', params=paramsSet, headers=headers, json=payload, allow_redirects=False)
            if response.status_code == 200:
                print("WIFI configurado con exito")
                print(response.text)            
    except Exception as e:
        print(f"Error fatal: {str(e)}")
        return

def cambiar_canal():
    try:
        paramsGet = {'name': 'GetWlanSettings',}
        paramsSet = {'name': 'SetWlanSettings',}
        payload["_"] = int(time.time() * 1000)
        payload["id"] = f"{random.uniform(0, 100):.1f}"
        payload["method"] = "GetWlanSettings"
        payload["params"] = {}

        response = requests.post('http://192.168.1.1/jrd/webapi', params=paramsGet, headers=headers, json=payload, verify=False)

        if response.status_code == 200:
            AP2G = response.json()['result']['AP2G']
            AP5G = response.json()['result']['AP5G']
            AP2G_guest = response.json()['result']['AP2G_guest']
            AP5G_guest = response.json()['result']['AP5G_guest'] 
            payload['_'] = int(time.time() * 1000)
            payload["id"] = f"{random.uniform(0, 100):.1f}"
            payload["method"] = 'SetWlanSettings'
            payload["params"] = {
                'WiFiState': 0,
                'ApState': 0,
                'preferred': 0,
                'WlanAPMode': 0,
                'selectMode': 1,
                'WiFiOffTime': 0,
                'isolate': 0,
                'SleepMode': 0,
                'AP2G': AP2G,
                'AP5G': AP5G,
                'AP2G_guest': AP2G_guest,
                'AP5G_guest': AP5G_guest,
                }
            canales = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
            canal_actual = AP2G["CurChannel"]
            canales.remove(canal_actual)
            canal_nuevo = random.choice(canales)
            payload["params"]['AP2G']['Channel'] = canal_nuevo   
            print("configurando WIFI, si todo sale bien la señal wifi deberia reiniciarse  ")
            response = requests.post('http://192.168.1.1/jrd/webapi', params=paramsSet, headers=headers, json=payload, allow_redirects=False)
            if response.status_code == 200:
                print("WIFI configurado con exito")
                print(response.text)            
    except Exception as e:
        print(f"Error fatal: {str(e)}")
        return


def chek_Pizarra():
    mac_raspberry = ['B8:27:EB', 'DC:A6:32', 'E4:5F:01', '28:CD:C1', '2C:CF:67', 'D8:3A:DD', '88:A2:9E', '98:FE:54' ]
    pizarra = False
    for i in range(2):
        try:
            params = {'name': 'GetConnectedDeviceList',}
            payload["_"] = int(time.time() * 1000)
            payload["id"] = f"{random.uniform(0, 100):.1f}"
            payload["method"] = "GetConnectedDeviceList"
            payload["params"] = {}
            response = requests.post('http://192.168.1.1/jrd/webapi', params=params, headers=headers, json=payload, verify=False)
            if response.status_code == 200:
                deviceList = response.json()['result']['ConnectedList']
                for device in deviceList:
                    if device['ConnectType'] != 4: 
                        mac = device['MacAddress']
                        prefijo = mac[:8].upper()
                        print(mac)
                        if prefijo in mac_raspberry:  
                            pizarra = True
                            break
                if pizarra:
                    break
        except Exception as e:
            print(f"Error fatal: {str(e)}")
            return
        time.sleep(10)
        
        
    if pizarra:
        print('Pizarra detectada')
    else:
        cambiar_canal()
        print('Pizarra NO detectada')

try:
    orden = sys.argv[1]   
except Exception as e:
    print(f"Error __Faltan argumentos__: {str(e)}")
    quit()


if orden == "cambiar_canal":
    logear()
    time.sleep(2)
    cambiar_canal()
elif orden == "configurar":
    aceptar_condiciones()  
    time.sleep(2)  
    logear()
    time.sleep(2)
    cambiar_clave()
    time.sleep(2)
    configurar_wifi()
elif orden == "check_Pizarra":
    logear()
    time.sleep(2)
    chek_Pizarra()