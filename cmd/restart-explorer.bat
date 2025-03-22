@echo off
PowerShell -Command "Stop-Process -Name explorer -Force"
PowerShell -Command "Start-Process explorer"
