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
import time
import sys
import xml.etree.ElementTree as ET
import fileinput
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
import selenium.webdriver.chrome.service as service


#os.environ["SE_OFFLINE"] = "true"

resultado = {
        'Telefonica': '', 
        'Modelo_Dispositivo': '', 
        'Codigo_SIM': '',
        'Senal': '', 
        'Senal_Calidad': '', 
        'Id_Celda': '', 
        'Disp_Conectados_Wifi': '',
        'Tarjeta_SIM': '',
        'Estado_Coneccion': '',
        'Red_Conectada': '',
        'Modo_Conec_Configurado': '',
        'Modo_Busq_Red_Configurado': '',
        'Red_Configurada': '',
        'Datos_Moviles': '',  
    }


class SeleniumManager:
    """A context manager for Selenium WebDriver."""
    def __init__(self):
        self.driver = None

    def __enter__(self):
        options = webdriver.ChromeOptions()
        options.add_argument("--headless")
        options.add_argument('--ignore-certificate-errors')
        options.add_argument("--test-type")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-setuid-sandbox")
        options.binary_location = "/home/ventas/.Auto/chromium-browser"
        self.driver = webdriver.Chrome(executable_path="/home/ventas/.Auto/chromedriver", options=options)
        self.driver.implicitly_wait(10)
        self.driver.set_page_load_timeout(10)
        self.driver.set_script_timeout(5)
        return self.driver
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        # Teardown logic (e.g., quitting the driver)
        if self.driver:
            self.driver.quit()
        # You can add exception handling logic here if needed


def Huawey():
    
    no_loguin_api = ['api/monitoring/status', 'api/net/current-plmn', 'api/device/basic_information', 'api/monitoring/converged-status' ]
    loguin_api = ['api/monitoring/status',
                'api/net/current-plmn',
                'api/device/basic_information',
                'api/monitoring/converged-status',
                'api/net/net-mode',
                'api/device/information',
                'api/device/signal',
                'api/dialup/mobile-dataswitch',]

    DatosUtiles = {'Telefonica': '', 'Nivel_Senal':'', 'Modelo_Dispositivo':'', 'Codigo_SIM':'', 'Senal_Calidad':'', 'Id_Celda':'', 'Dis_conectados':''}
    Tarjeta_SIM ={ '257':'OK' }
    Tarjeta_SIM.update(dict.fromkeys(['255','256','258','259','260','261'], 'NO_SIM'))
    Estado_Coneccion = {'900':'Conectando', '901':'Conectado', '902':'Desconectado', '903':'Desconectando'}
    Red_Conectada = {'0':'Sin servicio'}
    Red_Conectada.update(dict.fromkeys(['1','2','3','15','16','21','22','23','27'], '2G'))
    Red_Conectada.update(dict.fromkeys(['4','5','6','7','8','9','10','11','12','13','14','17','18','24','25','26','28','29','30','31','32','33','34','35','36','41','42','43','44','45','46','61','62','63','64','65','81'], '3G'))
    Red_Conectada.update(dict.fromkeys(['19','101','1011'], '4G'))
    Modo_Conec_Configurado = {'0':'Manual', '1':'Automatico',}
    Modo_Busq_Red_Configurado = {'0':'Automatico', '1':'Manual',}
    Red_Configurada = {'00':'Automatico', '01':'2G', '02':'3G', '03':'4G'}
    Datos_Moviles = {'0': 'Deshabilitado', '1': 'Habilitado'}

    def login(driver):
        driver.get("http://192.168.8.1/html/home.html")
        driver.find_element(By.ID, "logout_span").click()
        element = driver.find_element(By.ID, "username")
        element.send_keys(base64.b64decode("YWRtaW4=").decode("utf-8"))
        element.send_keys(Keys.ENTER)
        element = driver.find_element(By.ID, "password")
        element.send_keys(base64.b64decode("MTk3NjIyMTI=").decode("utf-8"))
        element.send_keys(Keys.ENTER)
        time.sleep(1)
        
    def guardar_Inf(respuesta):
        default = ET.fromstring("<nada></nada>")         
        resultado['Telefonica'] = respuesta.get('api/net/current-plmn', default).findtext('ShortName', '')
        resultado['Modelo_Dispositivo'] = respuesta.get('api/device/basic_information', default).findtext('devicename', '')
        resultado['Codigo_SIM'] = respuesta.get('api/device/information', default).findtext('Iccid', '')
        resultado['Id_Celda'] = respuesta.get('api/device/signal', default).findtext('cell_id', '')
        resultado['Disp_Conectados_Wifi'] = respuesta.get('api/monitoring/status', default).findtext('CurrentWifiUser', '')
        resultado['Tarjeta_SIM'] = Tarjeta_SIM.get(str(respuesta.get('api/monitoring/converged-status', default).findtext('SimState', '')), '')
        resultado['Estado_Coneccion'] = Estado_Coneccion.get(str(respuesta.get('api/monitoring/status', default).findtext('ConnectionStatus', '')), '')
        resultado['Red_Conectada'] = Red_Conectada.get(str(respuesta.get('api/monitoring/status', default).findtext('CurrentNetworkTypeEx', '')), '')
        resultado['Red_Configurada'] = Red_Configurada.get(str(respuesta.get('api/net/net-mode', default).findtext('NetworkMode', '')), '')
        resultado['Datos_Moviles'] = Datos_Moviles.get(str(respuesta.get('api/dialup/mobile-dataswitch', default).findtext('dataswitch', '')), '')
        
        if '3G' in resultado['Red_Conectada']:
            resultado['Senal'] = respuesta.get('api/device/signal', default).findtext('rscp', '')
            resultado['Senal_Calidad'] = respuesta.get('api/device/signal', default).findtext('ecio', '')
        elif '4G' in resultado['Red_Conectada']:
            resultado['Senal'] = respuesta.get('api/device/signal', default).findtext('rsrp', '') 
            resultado['Senal_Calidad'] = respuesta.get('api/device/signal', default).findtext('sinr', '')
        elif '2G' in resultado['Red_Conectada']:
            resultado['Senal'] = respuesta.get('api/device/signal', default).findtext('rssi', '')
        
        
        for key, value in resultado.items():
            # if not value == '':
            os.system(f""" sed -i 's/^{key}=.*/{key}={value}/' info.ini""")
            #print(key+' = '+str(value))
            

    def getInfo():
        try:
            respuesta = {}
            response = requests.get("http://192.168.8.1/")  
            cookies = response.cookies.get_dict()
            for itmes in no_loguin_api:
                response = requests.get('http://192.168.8.1/'+itmes, cookies=cookies, verify=False, timeout=10)
                respuesta[itmes] = ET.fromstring(response.content)
               
            guardar_Inf(respuesta)
            return resultado
            
        except Exception as e:
            #logear()
            print(f"Error fatal: {str(e)}")


    def getInfo2():
        with SeleniumManager() as driver:
            #driver = webdriver.Chrome(executable_path="/home/ventas/.Auto/chromedriver", options=options)
            #driver.implicitly_wait(10)
            
            #try:
            login(driver)
            js_script = """
                const url = arguments[0];
                const callback = arguments[1]; // El callback es el segundo argumento para execute_async_script
                fetch(url)
                    .then(response => callback(response.text()))
                    .catch(error => callback({error: error.message}));
                """
            respuesta = {}
            for items in loguin_api:
                url="http://192.168.8.1/"+items
                response_data = driver.execute_async_script(js_script, url)
                respuesta[items] = ET.fromstring(response_data)
                #print(response_data)

            guardar_Inf(respuesta)
            
            return resultado
                
            #except Exception as e:
                #print(f"Error fatal: {str(e)}")

    def habilitarDatos_Moviles():
        url="//"
        js_script0 = """
            const url = arguments[0];
            const callback = arguments[1]; // El callback es el segundo argumento para execute_async_script
            fetch("http://192.168.8.1/html/mobilenetworksettings.html")
            .then(response => callback(response.text()))
            .catch(error => callback({error: error.message}));
            """
        js_script = """
            const url = arguments[0];
            const callback = arguments[1]; // El callback es el segundo argumento para execute_async_script
            fetch("http://192.168.8.1/api/dialup/mobile-dataswitch", {
              "headers": {"__requestverificationtoken": url},
              "body": "<request><dataswitch>1</dataswitch></request>",
              "method": "POST"
                })
            .then(response => callback(response.text()))
            .catch(error => callback({error: error.message}));
            """
        html_doc = driver.execute_async_script(js_script0, url)
        soup = BeautifulSoup(html_doc, 'lxml')
        tokent = soup.head.find_all('meta', attrs={'name' : 'csrf_token'})
        tokent = tokent[1].get('content')
        driver.execute_async_script(js_script, tokent)    
        
        
    def configurarRed():
        url="//"
        js_script0 = """
            const url = arguments[0];
            const callback = arguments[1]; // El callback es el segundo argumento para execute_async_script
            fetch("http://192.168.8.1/html/mobilenetworksettings.html")
            .then(response => callback(response.text()))
            .catch(error => callback({error: error.message}));
            """
        js_script = """
            const url = arguments[0];
            const callback = arguments[1]; // El callback es el segundo argumento para execute_async_script
            fetch("http://192.168.8.1/api/net/net-mode", {
              "headers": {"__requestverificationtoken": url},
              "body": "<request><NetworkMode>00</NetworkMode><NetworkBand>3FFFFFFF</NetworkBand><LTEBand>7FFFFFFFFFFFFFFF</LTEBand></request>",
              "method": "POST"
                })
            .then(response => callback(response.text()))
            .catch(error => callback({error: error.message}));
            """
        html_doc = driver.execute_async_script(js_script0, url)
        soup = BeautifulSoup(html_doc, 'lxml')
        tokent = soup.head.find_all('meta', attrs={'name' : 'csrf_token'})
        tokent = tokent[1].get('content')
        driver.execute_async_script(js_script, tokent)    


    try:
        getInfo2()
    except Exception as e:
        getInfo()
    
    quit()

        

def Alcatel():
    headers = {
        'Referer': 'http://192.168.1.1/index.html',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',
        '_TclRequestVerificationKey': 'KSDHSDFOGQ5WERYTUIQWERTYUISDFG1HJZXCVCXBN2GDSMNDHKVKFsVBNf',
        '_TclRequestVerificationToken': '',
        }

    data_loguin = { 'id': '12', 'jsonrpc': '2.0', 'method': 'Login', 'params': { 'UserName': 'dc13ibej?7', 'Password': 'df<6cgjo3201Y[[Z', },}
    data = {'id': '12', 'jsonrpc': '2.0', 'method': 'GetLoginState', 'params': {}, }
    cookies = {'obj': '%7B%22_%24s_f%22%3A0%2C%22_%24p%22%3A%22%40BBHAEMHJKJK5776%22%7D', 't': '',}

    Get_info = ['GetSimStatus', 'GetSystemStatus', 'GetNetworkInfo', 'GetSystemInfo', 'GetNetworkSettings', 'GetConnectedDeviceList', 'GetConnectionSettings' ]
    DatosUtiles = {'Telefonica': '', 'Nivel_Senal':'', 'Modelo_Dispositivo':'', 'Codigo_SIM':'', 'Senal_Calidad':'', 'Id_Celda':'', 'Dis_conectados':''}
    Tarjeta_SIM ={ '0':'NO_SIM', '1':'Detectada', '4':'Bloqueada', '6':'Invalida', '7':'OK' }
    Estado_Coneccion = {'0':'Desconectado', '1':'Conectando', '2':'Conectado', '3':'Desconectando'}
    Red_Conectada = {'0':'Sin servicio', '1':'GPRS(2G)', '2':'EDGE(2G)', '3':'HSPA(3G)', '4':'HSUPA(3G)', '5':'UMTS(3G)', '6':'HSPA+(3G)', '7':'DCHSPA+(3G)', '8':'LTE(4G)', '9':'LTE+(4G+)', '11':'GSM(2G)',}
    Modo_Conec_Configurado = {'0':'Manual', '1':'Automatico',}
    Modo_Busq_Red_Configurado = {'0':'Automatico', '1':'Manual',}
    Red_Configurada = {'0':'Automatico', '1':'2G', '2':'3G', '3':'4G', '5':'4G'}

    def encode(text):
        if not text:
            return ""
        key = "e5dl12XYVggihggafXWf0f2YSf2Xngd1"
        #key = "AKFKHH45665sdafa456465adsfdsafdsadfasfdsfaf456465gasdgdsageagdsagdsJHGje" #para generar parte de cookies['obj']
        output = []

        for i, char in enumerate(text):
            char_code = ord(char)
            key_code = ord(key[i % len(key)])

            output.append(
                (key_code & 0xF0) | ((char_code & 0x0F) ^ (key_code & 0x0F))
            )
            output.append(
                (key_code & 0xF0) | ((char_code >> 4) ^ (key_code & 0x0F))
            )
     
        return ''.join(chr(c) for c in output)

    def logear():
        dd = {"id":"12","jsonrpc":"2.0","method":"HeartBeat","params":{}}
        try:
            response = requests.post('http://192.168.1.1/jrd/webapi', headers=headers, json=dd, verify=False, timeout=10, allow_redirects=False)
            if "need login" in response.text or "Authentication Failure" in response.text:
                while True:
                    response = requests.post('http://192.168.1.1/jrd/webapi', headers=headers, json=data_loguin, verify=False, timeout=10, allow_redirects=False)
                    if response.status_code == 200:
                        token = response.json()['result']['token']
                        token_codificado = encode(str(token))
                        headers['_TclRequestVerificationToken'] = token_codificado
                        cookies['t'] = "1D4B9765B16C3A64AD97489B1610498B"+urllib.parse.quote(token_codificado)
                        break
                    print("Error al Logear")
                    time.sleep(2)
                
        except Exception as e:
            print(f"Error fatal: {str(e)}")

    def ejecutar(accion, parametro = ""):
        data = {}
        if accion == "conectar":
            data = {'id': '12', 'jsonrpc': '2.0', 'method': 'Connect', 'params': {},}
        elif accion == "desconectar":
            data = {"id":"12","jsonrpc":"2.0","method":"DisConnect","params":{"ReconnectFlag":1}}
        elif accion == "modoConeccionAuto":
            data = {"id":"12","jsonrpc":"2.0","method":"SetConnectionSettings","params":{"ConnectMode":1,"RoamingConnect":0,"PdpType":3}}
        elif accion == "configurarRed":
            if parametro == "Auto":
                modo = 0
            elif parametro == "2G":
                modo = 1
            elif parametro == "3G":
                modo = 2
            elif parametro == "4G":
                modo = 5
            else:
                return
            data = {"id":"12","jsonrpc":"2.0","method":"SetNetworkSettings","params":{"NetworkMode":modo,"NetselectionMode":0,"NetworkBand":255,"DomesticRoam":0,"DomesticRoamGuard":0}}
        elif accion == "reiniciar":
            data = {"id":"12","jsonrpc":"2.0","method":"SetDeviceReboot","params":{}}
        elif accion == "informacion":
            print(getInfo())
            return 
        else:
            return
        response = requests.post('http://192.168.1.1/jrd/webapi', cookies=cookies, json=data, headers=headers, verify=False, timeout=10, allow_redirects=False)
        return(json.dumps(response.json(), indent=4))
    
    def guardar_Inf(respuesta):       
        resultado['Telefonica'] = respuesta.get('GetSimStatus', {}).get('SPN', '')
        resultado['Modelo_Dispositivo'] = respuesta.get('GetSystemInfo', {}).get('DeviceName', '')
        resultado['Codigo_SIM'] = respuesta.get('GetSystemInfo', {}).get('ICCID', '')
        resultado['Id_Celda'] = respuesta.get('GetNetworkInfo', {}).get('CellId', '')
        resultado['Disp_Conectados_Wifi'] = respuesta.get('GetConnectedDeviceList', {}).get('TotalConnNum', '')
        resultado['Tarjeta_SIM'] = Tarjeta_SIM.get(str(respuesta.get('GetSimStatus', {}).get('SIMState')), '')
        resultado['Estado_Coneccion'] = Estado_Coneccion.get(str(respuesta.get('GetSystemStatus', {}).get('ConnectionStatus')), '')
        resultado['Red_Conectada'] = Red_Conectada.get(str(respuesta.get('GetSystemStatus', {}).get('NetworkType')), '')
        resultado['Modo_Conec_Configurado'] = Modo_Conec_Configurado.get(str(respuesta.get('GetConnectionSettings', {}).get('ConnectMode')), '')
        resultado['Modo_Busq_Red_Configurado'] = Modo_Busq_Red_Configurado.get(str(respuesta.get('GetNetworkSettings', {}).get('NetselectionMode')), '')
        resultado['Red_Configurada'] = Red_Configurada.get(str(respuesta.get('GetNetworkSettings', {}).get('NetworkMode')), '')
        if '3G' in resultado['Red_Conectada']:
            resultado['Senal'] = respuesta.get('GetNetworkInfo', {}).get('RSCP', '') 
            resultado['Senal_Calidad'] = respuesta.get('GetNetworkInfo', {}).get('EcIo', '')
        elif '4G' in resultado['Red_Conectada']:
            resultado['Senal'] = respuesta.get('GetNetworkInfo', {}).get('RSRP', '') 
            resultado['Senal_Calidad'] = respuesta.get('GetNetworkInfo', {}).get('SINR', '')
        elif '2G' in resultado['Red_Conectada']:
            resultado['Senal'] = respuesta.get('GetNetworkInfo', {}).get('RSSI', '') 
         
               
        for key, value in resultado.items():
            #if not value == '':
            os.system(f""" sed -i 's/^{key}=.*/{key}={value}/' info.ini""")
            #print(key+' = '+str(value))
    
    def getInfo():
        try:
            respuesta = {}
            for itmes in Get_info:
                data['method'] = itmes
                response = requests.post('http://192.168.1.1/jrd/webapi', cookies=cookies, headers=headers, json=data, verify=False, timeout=10, allow_redirects=False)
                respuesta[itmes] = response.json()['result']
                #print(json.dumps(response.json()['result'], indent=4))
            
            guardar_Inf(respuesta)            
            #return json.dumps(resultado, indent=4)
            return resultado
        except Exception as e:
            logear()
            print(f"Error fatal: {str(e)}")
           




    logear()
    getInfo()

    quit()
    
    accion = ""
    parametro = ""
    try:
        accion = sys.argv[1]
        parametro = sys.argv[2]
    except Exception as e:
            print(f"Error fatal: {str(e)}")

    logear()
    ejecutar(accion, parametro)
    

try:
    modem = sys.argv[1]
    #parametro = sys.argv[2]
except Exception as e:
    print(f"Error __Faltan argumentos__: {str(e)}")
    quit()
        
if modem == 'Huawei':
    Huawey()
elif modem == 'Alcatel':
    Alcatel()
else:
    print(f"Error __Moden '{modem}' no identificado__")

#1e9e544039e5b1
