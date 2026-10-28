*** Keywords ***
[Example][Main] ตรวจสอบการแสดงหน้าหลัก Example ถูกต้องหรือไม่
    ${result_verify_main_title}=    Run Keyword And Return Status    Browser.Wait For Condition    Text    ${example_main.Example_Title_Text}    contains    ${tc1.example_title}
    IF    '${result_verify_main_title}' == 'False'
        Fail    [ERROR][TC1] ตรวจสอบการแสดงหน้าหลัก Example ไม่พบ Title : ${tc1.example_title}
    END
