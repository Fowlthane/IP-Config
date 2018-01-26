@TITLE IP Config v1.0
@echo off
goto Continue
:MainMenu
@echo off
cls
echo Please Enter your Network Name!
echo Do you know your Network Name?
echo.
echo [1] Yes
echo [2] No
echo.
echo [0] Quit
echo.
:choice1
SET /P C=Enter your Choice: 
for %%? in (1) do if /I "%C%"=="%%?" goto EnterNetName 
for %%? in (2) do if /I "%C%"=="%%?" goto OpenControlPanel
for %%? in (0) do if /I "%C%"=="%%?" goto end
goto choice1

:EnterNetName
@echo off
cls
set /p Network_Name=Enter your Network Name: 
goto PostAdmin

:OpenControlPanel
start control netconnections
goto EnterNetName

:Continue
:: BatchGotAdmin
:-------------------------------------
REM  -- Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM -- If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
	goto MainMenu
:--------------------------------------
@echo off
:PostAdmin
cls
echo Network Name: %Network_Name%
echo.
echo Network Settings: 
echo [1] Set DHCP IP ^& DNS
echo [2] Set Static DNS Only
echo [3] Set Static IP With DNS 
echo.
echo [4] Show current settings
echo.
echo [9] Main Menu
echo [0] Quit
echo. 

:choice2
SET /P C=Enter your Choice: 
for %%? in (1) do if /I "%C%"=="%%?" goto 1
for %%? in (2) do if /I "%C%"=="%%?" goto 2
for %%? in (3) do if /I "%C%"=="%%?" goto 3
for %%? in (4) do if /I "%C%"=="%%?" goto 4
for %%? in (9) do if /I "%C%"=="%%?" goto MainMenu
for %%? in (0) do if /I "%C%"=="%%?" goto end
goto choice2

:1
@echo off
echo.
echo Resetting IP Address ^& DNS to DHCP . . .
netsh int ip set address "%Network_Name%" dhcp
netsh int ip set dns "%Network_Name%" dhcp

ipconfig /renew "%Network_Name%"
cls
echo Here are the new settings for "%Network_Name%"
netsh int ip show config "%Network_Name%"

pause 
goto PostAdmin

:2
@echo off 
echo.
echo Please enter Static DNS Information!

echo.
set /p DNS_Addr=Primary DNS: 

echo.
set /p DNS_Addr_2=Secondary DNS: 

echo.
echo Configuring DNS Server . . .
netsh interface ipv4 set dns "%Network_Name%" static %DNS_Addr% primary
netsh interface ipv4 add dns "%Network_Name%" %DNS_Addr_2% 2
cls
echo Here are the new settings for "%Network_Name%"
netsh int ip show config "%Network_Name%"

pause 
goto PostAdmin

:3
@echo off 
echo.
echo Please enter Static IP Address ^& DNS Information!

echo.
set /p IP_Addr=Static IP Address: 

echo.
set /p Sub_Mask=Subnet Mask: 

echo.
set /p D_Gate=Default Gateway: 

echo.
set /p DNS_Addr=Primary DNS: 

echo.
set /p DNS_Addr_2=Secondary DNS: 

echo.
echo Configuring Static IP Address ^& DNS Server . . .
netsh interface ip set address "%Network_Name%" static %IP_Addr% %Sub_Mask% %D_Gate% 1 
netsh interface ipv4 set dns "%Network_Name%" static %DNS_Addr% primary
netsh interface ipv4 add dns "%Network_Name%" %DNS_Addr_2% 2
cls
echo Here are the new settings for "%Network_Name%"
netsh int ip show config "%Network_Name%"

pause 
goto PostAdmin

:4
@echo off
echo.
echo Here are the settings of your "%Network_Name%"
netsh int ip show config "%Network_Name%"
pause
goto PostAdmin

:end
