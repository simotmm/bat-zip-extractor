:: configuration
@echo off
setlocal EnableDelayedExpansion
set CHUNK=100

:: worker mode
if not "%~1"=="" goto :WORKER

:: master mode
echo automatic extraction of .zip files in the current folder.
set nzipfiles=0
for %%F in (*.zip) do set /a nzipfiles+=1
if %nzipfiles% EQU 0 (
    echo no .zip files found, nothing to extract.
    pause
    exit /b
)
echo %nzipfiles% .zip files found.
set start=1

:: launch
:LAUNCH
set /a end=start+CHUNK-1
if %end% GTR %nzipfiles% set end=%nzipfiles%
echo launching worker for files %start% to %end%.
start "" "%~f0" %start% %end%
set /a start=end+1
if %start% LEQ %nzipfiles% goto LAUNCH
echo all workers launched.
exit /b

:: worker (child process)
:WORKER
set START=%1
set END=%2
echo worker: processing files %START% to %END%.
set index=0
set processed=0
for %%F in (*.zip) do (
    set /a index+=1
    if !index! GEQ %START% if !index! LEQ %END% (
        set /a processed+=1
        echo extracting '%%F' ^-> folder '%%~nF'.
        if not exist "%%~nF" mkdir "%%~nF"
        tar -xf "%%F" -C "%%~nF"
    )
)
echo worker completed: %processed% files processed.
exit /b