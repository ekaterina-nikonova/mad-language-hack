@echo off
set "PATH=%PATH%;C:\dev\flutter\bin;C:\flutter\flutter\bin;C:\Python313"
cd /d "%~dp0process\frontend"
echo [MAD Language] Starting Flutter Web Server on http://localhost:8085 ...
start http://localhost:8085
flutter run -d web-server --web-port 8085 --web-hostname localhost
