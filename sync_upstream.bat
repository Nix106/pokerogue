@echo off
setlocal
cd /d "%~dp0"

rem Runs sync_upstream.sh with Git Bash. Arguments are passed through.
set "GIT_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%GIT_BASH%" (
  echo Git Bash not found at "%GIT_BASH%".
  pause
  exit /b 1
)

"%GIT_BASH%" ./sync_upstream.sh %*
pause
