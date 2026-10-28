*** Settings ***
Library    Browser

# !!! ============================| Keywords |============================ !!!
Resource    ../resources/keywords/common.robot
Resource    ../resources/keywords/example_login.robot
Resource    ../resources/keywords/example_main.robot

# !!! ============================| Variables |============================ !!!
# element selector
Resource    ../resources/variables/element_selector/selector_login.robot
Resource    ../resources/variables/element_selector/selector_main.robot
# test data
Resource    ../resources/variables/test_data.robot
