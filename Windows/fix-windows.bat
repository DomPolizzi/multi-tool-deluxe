@echo off
SETLOCAL ENABLEEXTENSIONS
set LOGFILE=C:\logs\maintenance_log.txt
set LOGDIR=%~dp0logs
set DATESTAMP=%DATE%_%TIME%

REM Check if the log directory exists, and if not, create it
if not exist %LOGDIR% (
    mkdir %LOGDIR%
)

echo Maintenance script started at %DATESTAMP% > %LOGFILE%

REM Check for administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrative privileges confirmed.
    echo =====================================
    echo Maintenance script started at %DATESTAMP%
) else (
    echo This script requires administrative privileges.
    goto :EOF
)

REM Prompt for deleting temp files
echo Do you want to delete temporary files? (Y/N)
set /p DELTEMP=Type Y or N and press Enter: 
if /I "%DELTEMP%" EQU "Y" (
    echo [%DATESTAMP%] Deleting temporary files... >> %LOGFILE%
    del /q/f/s %TEMP%\* >> %LOGFILE% 2>&1
    echo Temporary files deleted.
) else (
    echo Skipping deletion of temporary files.
)

REM Run System File Checker
echo [%DATESTAMP%] Running System File Checker... >> %LOGFILE%
sfc /scannow >> %LOGFILE% 2>&1

REM Run DISM commands
echo [%DATESTAMP%] Running DISM operations... >> %LOGFILE%
DISM /Online /Cleanup-Image /CheckHealth >> %LOGFILE% 2>&1
DISM /Online /Cleanup-Image /ScanHealth >> %LOGFILE% 2>&1
DISM /online /Cleanup-Image /StartComponentCleanup >> %LOGFILE% 2>&1
REM Consider whether /ResetBase is needed for your scenario
REM DISM /online /Cleanup-Image /StartComponentCleanup /ResetBase >> %LOGFILE% 2>&1
DISM /Online /Cleanup-Image /RestoreHealth >> %LOGFILE% 2>&1

REM Schedule Check Disk on reboot
echo [%DATESTAMP%] Scheduling Check Disk on next reboot... >> %LOGFILE%
echo y | chkdsk /r >> %LOGFILE% 2>&1

REM Resetting Network Components
echo [%DATESTAMP%] Resetting Winsocket >> %LOGFILE%
netsh winsock reset >> %LOGFILE% 2>&1
echo [%DATESTAMP%] IP Reset >> %LOGFILE%
netsh int ip reset >> %LOGFILE% 2>&1
ipconfig /flushdns >> %LOGFILE% 2>&1
ipconfig /registerdns >> %LOGFILE% 2>&1
ipconfig /release >> %LOGFILE% 2>&1
ipconfig /renew >> %LOGFILE% 2>&1

REM Shutdown command with delay
echo [%DATESTAMP%] System will restart in 2 seconds to perform scheduled tasks. >> %LOGFILE%
shutdown /r /t 2

echo Maintenance tasks completed. Check %LOGFILE% and C:\Windows\Logs\DISM\dism.log for details.
ENDLOCAL
pause
