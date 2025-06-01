import re
from playwright.sync_api import Playwright, sync_playwright, expect
import sys
import base64

def alcatel(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto("http://192.168.1.1/index.html#/resetReboot")
    page.locator(".el-input__inner").fill(base64.b64decode("MTk3NjIyMTI=").decode("utf-8"))
    page.locator(".btnLogin").click()
    page.locator('xpath=//*[@id="reboot"]/form/button').click()
    page.locator('xpath=//*[@id="no-ie-9"]/body/div[2]/div/div[3]/button[2]').click()
    page.wait_for_timeout(10000)
    
    # ---------------------
    context.close()
    browser.close()




def huawei(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()
    page.goto("http://192.168.8.1/html/home.html")
    page.locator("#logout_span").click()
    page.locator("#username").fill(base64.b64decode("YWRtaW4=").decode("utf-8"))
    page.locator("#password").fill(base64.b64decode("MTk3NjIyMTI=").decode("utf-8"))
    page.locator("#password").press("Enter")
    page.locator("#menu_settings").click()
    page.goto("http://192.168.8.1/html/reboot.html")
    page.locator("#reboot_apply_button").click()
    page.locator("#pop_confirm").click()
    page.wait_for_timeout(10000)

    # ---------------------
    context.close()
    browser.close()


with sync_playwright() as playwright:
    if sys.argv[1] == "Alcatel":
        alcatel(playwright)
    elif sys.argv[1] == "Huawei":
        huawei(playwright)


