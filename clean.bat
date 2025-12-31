@echo off
:: ================================================
::  ULTIMATE PC CLEANUP - Automatic Full Version
::  Runs everything automatically (no menus)
::  Clears Xbox, FiveM, Epic, browsers, Discord, temps, events + more
::  Space freed counter + optional restart at the end
::  Run as Administrator
:: ================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [X] This script must be run as Administrator.
    echo  Right-click the file and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

cls
echo ================================================
::  AUTOMATIC FULL PC CLEANUP STARTING...
echo ================================================
echo.
echo This script will automatically clean:
echo - Xbox apps
echo - FiveM / Epic Games cache
echo - Browser cache (Chrome, Edge, Firefox)
echo - Discord cache
echo - Temp files, Prefetch, Recycle Bin
echo - Run Disk Cleanup
echo - Clear Windows Event Logs
echo - Flush DNS, renew IP, clear thumbnails
echo.
echo 100% safe - starts in 5 seconds...
timeout /t 5 >nul

echo.
echo Closing common processes...
taskkill /f /im FiveM.exe >nul 2>&1
taskkill /f /im EpicGamesLauncher.exe >nul 2>&1
taskkill /f /im steam.exe >nul 2>&1
taskkill /f /im discord.exe >nul 2>&1
echo Done.
echo.

echo Calculating space before cleanup...
call :get_temp_size before_size
echo.

echo [1/8] Uninstalling Xbox apps...
powershell -command "Get-AppxPackage *xbox* | Remove-AppxPackage" >nul 2>&1
echo     Xbox apps removed.
echo.

echo [2/8] Clearing FiveM and Epic Games cache...
if exist "%LocalAppData%\FiveM" (
    rmdir /s /q "%LocalAppData%\FiveM\FiveM.app\data\cache" >nul 2>&1
    rmdir /s /q "%LocalAppData%\FiveM\FiveM.app\data\server-cache*" >nul 2>&1
    rmdir /s /q "%LocalAppData%\FiveM\FiveM.app\logs" >nul 2>&1
    rmdir /s /q "%LocalAppData%\FiveM\FiveM.app\crashes" >nul 2>&1
    echo     FiveM cache cleared.
)
rmdir /s /q "%LocalAppData%\EpicGamesLauncher\Saved\webcache*" >nul 2>&1
echo     Epic Games cache cleared.
echo.

echo [3/8] Clearing browser cache...
rmdir /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
rmdir /s /q "%LocalAppData%\Mozilla\Firefox\Profiles\*.default*\cache2" >nul 2>&1
echo     Browser cache (Chrome/Edge/Firefox) cleared.
echo.

echo [4/8] Clearing Discord cache...
rmdir /s /q "%AppData%\discord\Cache" >nul 2>&1
rmdir /s /q "%AppData%\discord\Code Cache" >nul 2>&1
rmdir /s /q "%AppData%\discord\GPUCache" >nul 2>&1
echo     Discord cache cleared.
echo.

echo [5/8] Clearing temp files + Recycle Bin...
rmdir /s /q "%LocalAppData%\Temp" >nul 2>&1
rmdir /s /q "C:\Windows\Temp" >nul 2>&1
mkdir "C:\Windows\Temp" >nul 2>&1
rmdir /s /q "C:\Windows\Prefetch" >nul 2>&1
mkdir "C:\Windows\Prefetch" >nul 2>&1
powershell -command "Clear-RecycleBin -Force" >nul 2>&1
echo     Temp files, Prefetch and Recycle Bin cleared.
echo.

echo [6/8] Running automatic Disk Cleanup...
cleanmgr /sagerun:1 >nul 2>&1
echo     Disk Cleanup completed.
echo.

echo [7/8] Clearing Windows Event Logs...
for /F "tokens=*" %%G in ('wevtutil.exe el') do (wevtutil cl "%%G" >nul 2>&1)
echo     Event logs cleared.
echo.

echo [8/8] Flushing DNS, renewing IP and clearing thumbnails...
ipconfig /flushdns >nul
ipconfig /renew >nul
ie4uinit.exe -ClearIconCache >nul 2>&1
ie4uinit.exe -show >nul 2>&1
echo     Network and thumbnail cache cleared.
echo.

echo Calculating space after cleanup...
call :get_temp_size after_size
set /a freed=before_size-after_size
set /a freed_mb=freed/1024/1024

echo.
echo ================================================
echo         FULL CLEANUP COMPLETED!
echo ================================================
echo.
echo Approximate space freed: %freed_mb% MB
echo Your PC is now clean, optimized and ready.
echo.
choice /c YN /n /m "Restart now for best results? (Y/N): "
if errorlevel 2 goto no_restart
echo.
echo Restarting in 10 seconds...
shutdown /r /t 10 /c "Restarting after full cleanup..."
goto eof

:no_restart
echo.
echo You can now close this window.
echo Enjoy your clean PC!
pause

:: ================================================
:: Function: Calculate size of main temp folders
:: ================================================
:get_temp_size
setlocal
set "total=0"
for %%F in (
    "%LocalAppData%\Temp"
    "C:\Windows\Temp"
    "%AppData%\discord\Cache"
    "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
    "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
    "%LocalAppData%\EpicGamesLauncher\Saved"
    "%LocalAppData%\FiveM\FiveM.app\data"
) do (
    if exist "%%~F" (
        for /f "tokens=3" %%A in ('dir /s /-c "%%~F" 2^>nul ^| find "File(s)"') do (
            set /a total+=%%A 2>nul
        )
    )
)
endlocal & set "%1=%total%"
goto :eof

:eof