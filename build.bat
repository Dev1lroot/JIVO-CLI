@echo off
title JIVO-CLI - Build
cls
goto buildBoth

:buildServer
taskkill /f /im server.exe /t
nim c -r --threads:on server.nim
exit /b 0

:buildClient
taskkill /f /im client.exe /t
nim c -r --threads:on client.nim
exit /b 0

:buildBoth
taskkill /f /im server.exe /t
taskkill /f /im client.exe /t
nim c --threads:on server.nim
nim c --threads:on client.nim
wt server.exe ; split-pane client.exe -u root -p root -h localhost:3080
exit /b 0

:runClient
taskkill /f /im client.exe /t
client.exe
exit /b 0

:runServer
taskkill /f /im server.exe /t
server.exe
exit /b 0

:runBoth
taskkill /f /im server.exe /t
taskkill /f /im client.exe /t
wt client.exe ; split-pane server.exe
exit /b 0