from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.select import Select
import time
import sys
import base64

options = webdriver.ChromeOptions()
#options.add_argument("--headless")
options.add_argument('--ignore-certificate-errors')
options.add_argument("--test-type")
options.add_argument("--no-sandbox")
options.add_argument("--disable-setuid-sandbox")
options.binary_location = "/home/ventas/.Auto/chromium-browser"

driver = webdriver.Chrome(executable_path="/home/ventas/.Auto/chromedriver", options=options)
driver.implicitly_wait(10)

if sys.argv[1] == "Alcatel":
    try:
        driver.get("http://192.168.1.1")
        print ("1")
        time.sleep(1)
        element = driver.find_element_by_xpath("//*[@id='login']/form/div/form/div[2]/input")
        element.send_keys(base64.b64decode("MTk3NjIyMTI=").decode("utf-8"))
        element.send_keys(Keys.ENTER)
        print ("2")
        time.sleep(1)
        driver.find_element_by_xpath("//*[@id='app']/div[2]/ul/li[3]/span").click()
        print ("3")
        time.sleep(1)
        driver.find_element_by_xpath("//*[@id='sideMenu']/ul/div[4]/li").click()
        print ("4")
        time.sleep(1)
        driver.find_element_by_xpath("//*[@id='sideMenu']/ul/div[4]/li/ul/li[2]").click()
        print ("5")
        time.sleep(1)
        driver.find_element_by_xpath("//*[@id='advance']/div/div[2]/div/form/div[1]/div[2]/div/div").click()
        time.sleep(1)
        canal = driver.find_element_by_xpath("//*[@id='no-ie-9']/body/div[2]/div/div[1]/ul/li[10]")
        driver.execute_script("arguments[0].scrollIntoView();", canal)
        canal.click()
        time.sleep(1)
        driver.find_element_by_xpath("//*[@id='advance']/div/div[2]/div/form/div[1]/div[5]").click()
        time.sleep(1)
        ancho = driver.find_element_by_xpath("//*[@id='no-ie-9']/body/div[3]/div/div[1]/ul/li[2]")
        ancho.click()
        time.sleep(1)
        print ("6")
        driver.find_element_by_xpath("//*[@id='advance']/div/div[2]/div/form/div[2]/div/div/button[1]").click()
        time.sleep(1)
        #driver.find_element_by_xpath("//*[@id='no-ie-9']/body/div[2]/div/div[3]/button[2]").click()
        driver.find_element_by_css_selector("button.el-button.el-button--default.el-button--primary").click()
        
        time.sleep(20)
    except:
        print(sys.exc_info())
    driver.quit()

elif sys.argv[1] == "Huawei":
    try:
        driver.get("http://192.168.8.1/html/home.html")
        print ("1")
        time.sleep(1)
        driver.find_element_by_id("logout_span").click()
        time.sleep(2)
        element = driver.find_element_by_id("username")
        element.send_keys(base64.b64decode("YWRtaW4=").decode("utf-8"))
        element.send_keys(Keys.ENTER)
        time.sleep(1)
        element = driver.find_element_by_id("password")
        element.send_keys(base64.b64decode("MTk3NjIyMTI=").decode("utf-8"))
        element.send_keys(Keys.ENTER)
        time.sleep(3)
        print ("2") 
        driver.get("http://192.168.8.1/html/wlanadvanced.html")
        print ("3")
        time.sleep(1)
        #driver.find_element_by_id("menu_settings").click()
        print ("4")
        time.sleep(1)
        #driver.find_element_by_id("wlan").click()
        print ("5")
        time.sleep(1)
        #driver.find_element_by_id("wlanadvanced").click()
        print ("6")
        time.sleep(1)
        js_code = """
            let select = document.querySelector('#select_WifiChannel');  // Selecciona el primer <select>
            if (select) {
                let input = document.createElement('input');
                input.type = 'text';
                input.name = select.name;
                input.id = select.id;
                input.value = 9;
            
                select.parentNode.replaceChild(input, select);
            }
            """
        driver.execute_script(js_code)
        time.sleep(1)
        ancho = Select(driver.find_element_by_id("select_wifiBandWidth"))
        ancho.select_by_value('0')
        time.sleep(1)
        ancho.select_by_value('20')
        time.sleep(1)
        driver.find_element_by_id("apply_button").click()
        print ("8")
        time.sleep(20)
    except:
        print(sys.exc_info())
    driver.quit()
