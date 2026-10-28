*** Settings ***
Resource    ../setting/import.robot

*** Test Cases ***
สามารถเข้าหน้าจอ BOT Document Platform ได้ และ แสดงรายการเมนูต่างๆของหน้า Home
    [Example][Login] Log in เข้า website ด้วย username และ password ที่กำหนด    ${common.example_url}    ${common.username}    ${common.password}
    [Example][Login] คลิกปุ่ม Log in
    [Example][Main] ตรวจสอบการแสดงหน้าหลัก Example ถูกต้องหรือไม่
