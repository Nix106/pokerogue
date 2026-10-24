@echo off
setlocal
cd /d "%~dp0"

where pnpm >nul 2>nul
if errorlevel 1 (
    echo pnpm not found. Install it with: npm install -g pnpm
    pause
    exit /b 1
)

if not exist node_modules (
    echo Installing dependencies...
    call pnpm install
)

if not exist assets\* (
    echo Fetching submodules ^(assets, locales^)...
    git submodule update --progress --init --recursive --depth 1
)
if not exist locales\* (
    echo Fetching submodules ^(assets, locales^)...
    git submodule update --progress --init --recursive --depth 1
)

echo Starting dev server...
start "PokeRogue Dev Server" cmd /k pnpm run start:dev

echo Waiting for server to be ready...
:waitloop
timeout /t 1 /nobreak >nul
curl -s -o nul http://localhost:8000
if errorlevel 1 goto waitloop

start "" http://localhost:8000
exit /b 0
