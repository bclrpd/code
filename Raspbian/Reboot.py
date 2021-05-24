from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.utils import ChromeType
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import sys

options = webdriver.ChromeOptions()
#options.headless = True
options.add_argument("--headless")
options.add_argument('--ignore-certificate-errors')
options.add_argument("--test-type")
options.add_argument("--no-sandbox")
options.add_argument("--disable-setuid-sandbox")

driver = webdriver.Chrome(ChromeDriverManager(chrome_type=ChromeType.CHROMIUM).install(),options=options)
#driver = webdriver.Chrome(executable_path="/usr/bin/chromedriver", options=options)
#driver = webdriver.Chrome()
driver.implicitly_wait(10)
try:
    #driver.get("https://www.google.com/")
    driver.get("http://192.168.1.1")
    print ("1")
except:
    print(sys.exc_info())

#time.sleep(3)

try:
    element = driver.find_element_by_xpath("//*[@id='login']/form/div/form/div[2]/input")
    element.send_keys("19762212")
    element.send_keys(Keys.ENTER)
    print ("2")
except:
    print(sys.exc_info())

try:  
    driver.find_element_by_xpath("//*[@id='app']/div[2]/ul/li[4]/span").click()
    print ("3")
except:
    print(sys.exc_info())
    
try:
    driver.find_element_by_xpath("//*[@id='sideMenu']/ul/div[2]/li/span").click()
    print ("4")
except:
    print(sys.exc_info())
    
try:
    driver.find_element_by_xpath("//*[@id='reboot']/form/button/span").click()
    print ("5")
except:
    print(sys.exc_info())

try:
    driver.find_element_by_xpath("//*[@id='no-ie-9']/body/div[2]/div/div[3]/button[2]/span").click()
    print ("6")
except:
    print(sys.exc_info())
#driver.close()
driver.quit()
