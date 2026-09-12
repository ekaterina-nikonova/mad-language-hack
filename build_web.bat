@echo off
set "PATH=%PATH%;C:\dev\flutter\bin;C:\flutter\flutter\bin;C:\Python313"
cd /d "%~dp0process\frontend"
echo [MAD Language] Compiling Flutter Web with Sound and Speech Synthesis...
call flutter build web --release
echo.
echo [MAD Language] Production build complete in process\frontend\build\web!
echo.
pause
