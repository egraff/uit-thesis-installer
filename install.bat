@echo off
cd /D "%~dp0"

mkdir uit-thesis
cd uit-thesis

..\msys64\usr\bin\sh.exe /setup-ult.sh
if errorlevel 1 goto ERROR
exit /b 0


:ERROR
echo Failed
pause
exit /b 1
