@echo off
setlocal EnableDelayedExpansion

:: =========================
:: CONFIG
:: =========================
set CHUNK=100

:: =========================
:: WORKER MODE
:: =========================
if not "%~1"=="" goto :WORKER

:: =========================
:: MASTER MODE
:: =========================
echo Automatic extraction of .zip files in the current folder.

set nzipfiles=0
for %%F in (*.zip) do set /a nzipfiles+=1

if %nzipfiles% EQU 0 (
    echo No .zip files found, nothing to extract.
    pause
    exit /b
)

echo %nzipfiles% .zip files found.

set start=1
:LAUNCH
set /a end=start+CHUNK-1
if %end% GTR %nzipfiles% set end=%nzipfiles%

echo Launching worker for files %start% to %end%
start "" "%~f0" %start% %end%

set /a start=end+1
if %start% LEQ %nzipfiles% goto LAUNCH

echo All workers launched.
exit /b

:: =========================
:: WORKER MODE
:: =========================
:WORKER
set START=%1
set END=%2

echo Worker processing files %START% to %END%

set index=0
set processed=0

for %%F in (*.zip) do (
    set /a index+=1
    if !index! GEQ %START% if !index! LEQ %END% (
        set /a processed+=1
        echo Extracting %%F ^> %%~nF
        if not exist "%%~nF" mkdir "%%~nF"
        tar -xf "%%F" -C "%%~nF"
    )
)

echo Worker completed: %processed% files processed.
exit /b
