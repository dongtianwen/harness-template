@echo off
pushd "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\start.ps1"
popd
pause
