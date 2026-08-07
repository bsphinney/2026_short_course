@echo off
REM ===========================================================================
REM  Get My Results  --  Proteomics Short Course 2026
REM
REM  DOUBLE-CLICK THIS FILE. That is the whole instruction.
REM
REM  Why this file exists: Windows refuses to run a downloaded PowerShell
REM  script (.ps1) by double-click -- it reports "is not digitally signed".
REM  A .cmd file has no such restriction, so this one launches the real script
REM  with -ExecutionPolicy Bypass, which ignores both the policy and the
REM  "downloaded from the internet" mark WITHOUT changing any setting on this
REM  computer. Nothing here is permanent and nothing is installed.
REM
REM  Keep this file in the same folder as the .ps1 script. The exact name of
REM  that script does not matter -- browsers and mail clients rename downloads
REM  (dropping the hyphens, adding "(1)"), so this looks for any plausible
REM  spelling rather than demanding one.
REM ===========================================================================

setlocal
pushd "%~dp0"

set "PS1="
for %%F in ("Get-My-Results.ps1" "GetMyResults.ps1" "Get My Results.ps1") do (
  if exist "%%~F" if not defined PS1 set "PS1=%%~F"
)
REM Still nothing? Take any .ps1 here whose name mentions results. This also
REM catches the "Get-My-Results (1).ps1" that a second download produces.
if not defined PS1 for %%F in (*esults*.ps1) do if not defined PS1 set "PS1=%%~F"

if not defined PS1 (
  echo.
  echo   Cannot find the PowerShell script that goes with this file.
  echo.
  echo   Both files must sit in the SAME folder:
  echo     %~dp0
  echo.
  echo   Looking for a file ending in .ps1 -- your instructor supplies it
  echo   alongside this one. If you only saved one, go back and save the other
  echo   next to it, then double-click this file again.
  echo.
  popd
  pause
  exit /b 1
)

echo   Using script: %PS1%
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
set "RC=%ERRORLEVEL%"

REM If PowerShell itself was blocked by a company/lab Group Policy, say so --
REM that cannot be overridden by -ExecutionPolicy Bypass, by design.
if not "%RC%"=="0" (
  echo.
  echo   If the message above mentioned "execution of scripts is disabled" or
  echo   a policy set by your administrator, this computer is locked down by IT
  echo   and the script cannot run. Use the typed command in Step 10 of your
  echo   handout instead -- it always works.
  echo.
  pause
)
popd
endlocal
