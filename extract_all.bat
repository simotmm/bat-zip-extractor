@echo off
setlocal EnableDelayedExpansion

rem === salva ora di inizio ===
set startTime=%TIME%

echo estrazione automatica file .zip nella cartella corrente.
set nzipfiles=0
for %%F in (*.zip) do (
    set /a nzipfiles+=1
)

if %nzipfiles% EQU 0 (
    echo nessun file .zip trovato, nulla da estrarre.
) else (
    echo %nzipfiles% file .zip trovati.
    echo estrazione in corso:
    set count=0
    for %%F in (*.zip) do (
        set /a count+=1
        echo estrazione file !count!: '%%F' -^> cartella '%%~nF'
        if not exist "%%~nF" mkdir "%%~nF"
        tar -xf "%%F" -C "%%~nF"
    )
    echo operazione completata con successo, !count! file .zip estratti.
)

rem === salva ora di fine ===
set endTime=%TIME%

rem === conversione ore:minuti:secondi,centesimi in secondi ===
for /f "tokens=1-4 delims=:., " %%a in ("%startTime%") do (
    set /a startSec=%%a*3600 + %%b*60 + %%c
)
for /f "tokens=1-4 delims=:., " %%a in ("%endTime%") do (
    set /a endSec=%%a*3600 + %%b*60 + %%c
)

rem === gestione cambio giorno ===
if %endSec% LSS %startSec% (
    set /a endSec+=86400
)

set /a elapsed=endSec-startSec

echo operazioni completate in %elapsed% secondi.
pause
