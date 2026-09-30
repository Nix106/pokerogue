@echo off
setlocal enabledelayedexpansion
set FOUND=0

for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8000" ^| findstr "LISTENING"') do (
    echo Stopping dev server ^(PID %%P^)...
    taskkill /PID %%P /T /F >nul 2>nul
    set FOUND=1
)

if "%FOUND%"=="0" (
    echo No server found running on port 8000.
) else (
    echo Game server stopped.
)

pause
