@echo off
REM ===========================================================================
REM  Get My Raw Data EASY.cmd - double-click THIS file, not the .ps1
REM
REM  Pick your name, pick your initials. No password to type.
REM  Keep this file and Get-My-Raw-Data-EASY.ps1 together in one folder.
REM ===========================================================================
setlocal
set "HERE=%~dp0"
if not exist "%HERE%Get-My-Raw-Data-EASY.ps1" (
  echo.
  echo   Cannot find Get-My-Raw-Data-EASY.ps1
  echo.
  echo   It must sit in the SAME folder as this file:
  echo     %HERE%
  echo.
  echo   Your instructor hands this one out - it is not on GitHub,
  echo   because it contains the class passwords.
  echo.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%HERE%Get-My-Raw-Data-EASY.ps1"
endlocal
