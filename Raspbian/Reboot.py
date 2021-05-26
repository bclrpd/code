from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
import time
import sys
import base64

options = webdriver.ChromeOptions()
options.add_argument("--headless")
options.add_argument('--ignore-certificate-errors')
options.add_argument("--test-type")
options.add_argument("--no-sandbox")
options.add_argument("--disable-setuid-sandbox")
options.binary_location = "/home/ventas/.Auto/chromium-browser"

driver = webdriver.Chrome(executable_path="/home/ventas/.Auto/chromedriver", options=options)
driver.implicitly_wait(10)

if sys.argv[1] == "Huawei":
    try:
        driver.get("http://192.168.1.1")
        print ("1")
        element = driver.find_element_by_xpath("//*[@id='login']/form/div/form/div[2]/input")
        element.send_keys(base64.b64decode("MTk3NjIyMTI=").decode("utf-8"))
        element.send_keys(Keys.ENTER)
        print ("2")
        driver.find_element_by_xpath("//*[@id='app']/div[2]/ul/li[4]/span").click()
        print ("3")
        driver.find_element_by_xpath("//*[@id='sideMenu']/ul/div[2]/li/span").click()
        print ("4")
        driver.find_element_by_xpath("//*[@id='reboot']/form/button/span").click()
        print ("5")
        driver.find_element_by_xpath("//*[@id='no-ie-9']/body/div[2]/div/div[3]/button[2]/span").click()
        print ("6")
    except:
        print(sys.exc_info())
    driver.quit()

elif sys.argv[1] == "Alcatel":
    try:
        driver.get("http://192.168.8.1")
        print ("1")
        element = driver.find_element_by_id("username")
        element.send_keys(base64.b64decode("YWRtaW4=").decode("utf-8"))
        element.send_keys(Keys.ENTER)
        element = driver.find_element_by_id("password")
        element.send_keys(base64.b64decode("MTk3NjIyMTI=").decode("utf-8"))
        element.send_keys(Keys.ENTER)
        print ("2") 
        driver.find_element_by_id("link_login_nocard").click()
        print ("3")
        driver.find_element_by_id("menu_settings").click()
        print ("4")
        driver.find_element_by_id("system").click()
        print ("5")
        driver.find_element_by_id("reboot").click()
        print ("6")
        driver.find_element_by_id("reboot_apply_button").click()
        print ("7")
        driver.find_element_by_id("pop_confirm").click()
        time.sleep(5)
        print ("8")
    except:
        print(sys.exc_info())
    driver.quit()
