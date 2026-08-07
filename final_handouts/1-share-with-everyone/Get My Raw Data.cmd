@echo off
REM ===========================================================================
REM  Get My Raw Data.cmd - double-click THIS file, not the .ps1
REM
REM  Windows refuses to run a downloaded .ps1 by double-click ("is not
REM  digitally signed"), so this wrapper launches it with that check bypassed
REM  for this one run only. Nothing is installed and nothing is changed on
REM  this PC.
REM
REM  Keep this file and Get-My-Raw-Data.ps1 together in the same folder.
REM ===========================================================================

setlocal
set "HERE=%~dp0"

if not exist "%HERE%Get-My-Raw-Data.ps1" (
  echo.
  echo   Cannot find Get-My-Raw-Data.ps1
  echo.
  echo   It must sit in the SAME folder as this file:
  echo     %HERE%
  echo.
  echo   Ask your instructor for it, or download it again from the course
  echo   GitHub page, then double-click this file once more.
  echo.
  pause
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%HERE%Get-My-Raw-Data.ps1"
endlocal
