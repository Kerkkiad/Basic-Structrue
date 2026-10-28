*** Keywords ***
[Example][Login] Log in เข้า website ด้วย username และ password ที่กำหนด
    [Arguments]    ${URL}    ${USERNAME}    ${PASSWORD}
    Set Browser Timeout    60 seconds
    New Browser    chromium    headless=False
    New Context    acceptDownloads=True
    New Page    ${URL}
    Browser.Fill Text    ${example_login.Username_Input}    ${USERNAME}
    Browser.Fill Text    ${example_login.Password_Input}    ${PASSWORD}

[Example][Login] คลิกปุ่ม Log in
    Browser.Click    ${example_login.Login_Button}
