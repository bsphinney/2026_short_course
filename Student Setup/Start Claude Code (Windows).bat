@echo off
REM
REM  Proteomics Short Course 2026 - one-click Claude Code launcher (Windows)
REM
REM  HOW TO USE: just double-click this file.
REM    - The first time, it installs Claude Code, then asks you to double-click once more.
REM    - After that, double-clicking always starts Claude Code.
REM
setlocal
cd /d "%~dp0"

echo ===============================================
echo    Proteomics Short Course 2026 - Claude Code
echo ===============================================
echo.

REM --- 1. Load the shared course API key from api-key.txt ---
if not exist "api-key.txt" (
  echo ERROR: Could not find api-key.txt next to this launcher.
  echo Keep all the files together in the same folder and try again.
  echo.
  pause
  exit /b 1
)
set /p ANTHROPIC_API_KEY=<api-key.txt
if "%ANTHROPIC_API_KEY%"=="" (
  echo ERROR: api-key.txt is empty. Ask your instructor for the course key.
  echo.
  pause
  exit /b 1
)
if "%ANTHROPIC_API_KEY%"=="PASTE-YOUR-COURSE-KEY-HERE" (
  echo ERROR: api-key.txt still has the placeholder, not the real key.
  echo Ask your instructor for the course key.
  echo.
  pause
  exit /b 1
)

REM --- 2. Install Claude Code the first time ---
where claude >nul 2>nul
if errorlevel 1 (
  echo First-time setup: installing Claude Code. This takes about a minute...
  echo.
  powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm https://claude.ai/install.ps1)"
  echo.
  echo -----------------------------------------------------
  echo    Install complete!
  echo    Now DOUBLE-CLICK this launcher one more time
  echo    to start Claude Code.
  echo -----------------------------------------------------
  echo.
  pause
  exit /b 0
)

REM --- 3. Start Claude Code ---
echo Starting Claude Code - type your questions right here in this window.
echo Tip: stay on the Sonnet 5 model (type /model to check). Type /exit when you're done.
echo.
claude
pause
