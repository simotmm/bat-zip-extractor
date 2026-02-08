:: configuration
@echo off
setlocal enabledelayedexpansion

set chunk=32
set worker_timeout=10
set master_timeout=30
set max_retry=3
set bar_width=20
set done_file=workers.done
set files_log=files_extracted.log

:: worker mode
if not "%~1"=="" goto :worker

:: master mode
echo automatic extraction of .zip files in the current folder.
echo.

:: start timer
set start_time=%TIME%

if exist "%done_file%" del "%done_file%"
if exist "%files_log%" del "%files_log%"

set nzipfiles=0
for %%f in (*.zip) do set /a nzipfiles+=1
if %nzipfiles% equ 0 (
    echo no .zip files found, nothing to extract.
    pause
    exit /b
)

set /a nchunks=(nzipfiles + chunk - 1) / chunk
echo total .zip files: %nzipfiles%.
echo n. max files per worker: %chunk%.
echo total workers: %nchunks%.
echo.

set start=1
set worker_id=0

:: launch workers
:launch
set /a worker_id+=1
set /a end=start+chunk-1
if %end% gtr %nzipfiles% set end=%nzipfiles%
echo launching worker %worker_id% (files %start% to %end%).
start "zip worker %worker_id%" cmd /c "%~f0" %start% %end%
set /a start=end+1
if %start% leq %nzipfiles% goto launch

echo.
echo all workers launched.
echo waiting for workers to complete.
echo.

:: wait for all workers
set show_bar=0
set last_completed=-1

:wait_workers
set completed=0
if exist "%done_file%" (
    for /f %%c in ('find /c /v "" ^< "%done_file%"') do set completed=%%c
)

if %completed% neq %last_completed% (
    set last_completed=%completed%
    set /a percent=completed*100/nchunks
    set /a filled=percent*bar_width/100

    if %show_bar% EQU 1 (
        set "inner_bar="
        for /l %%i in (1,1,!filled!) do set "inner_bar=!inner_bar!#"
        set /a empty=bar_width - filled
        if !empty! gtr 0 (
            for /l %%i in (1,1,!empty!) do set "inner_bar=!inner_bar!-"
        )
        set "bar= [!inner_bar!]"
    ) else (
        set "bar="
    )

    echo workers progress:!bar! !percent!%% (!completed!/%nchunks%^).
)

if %completed% lss %nchunks% (
    timeout /t 1 >nul
    goto wait_workers
)

echo.
echo all workers completed.

:: sum total files extracted
set total_files=0
if exist "%files_log%" (
    for /f %%f in (%files_log%) do set /a total_files+=%%f
)

if exist "%done_file%" del "%done_file%"
if exist "%files_log%" del "%files_log%"

echo total files extracted: %total_files%.

:: end timer
set end_time=%TIME%

call :time_to_cs "%start_time%" start_cs
call :time_to_cs "%end_time%" end_cs

set /a elapsed_cs=end_cs-start_cs
if %elapsed_cs% lss 0 set /a elapsed_cs+=24*60*60*100
set /a elapsed_sec=elapsed_cs/100

echo operations comlpeted in %elapsed_sec% seconds.

echo press enter to close the master process or wait %master_timeout% seconds.
choice /c y /n /d y /t %master_timeout% >nul
exit /b


:: worker (child process)
:worker
set start=%1
set end=%2

echo automatic extraction of .zip files in the current folder.
echo worker: processing files %start% to %end%.

set index=0
set processed=0

for %%f in (*.zip) do (
    set /a index+=1
    if !index! geq %start% if !index! leq %end% (
        set /a processed+=1
        echo extracting '%%f' -^> folder '%%~nf'.

        if not exist "%%~nf" mkdir "%%~nf"

        set retry=0
        :retry_extract
        tar -xf "%%f" -C "%%~nf" >nul 2>&1
        if errorlevel 1 (
            set /a retry+=1
            if !retry! lss %max_retry% (
                echo retry !retry! for "%%f"
                goto retry_extract
            ) else (
                echo failed extracting "%%f" after %max_retry% attempts
            )
        )
    )
)

echo worker completed: %processed% files processed (%start% to %end%).

:: log files processed
echo !processed! >> "%files_log%"

:: signal completion to master
echo done>>"%done_file%"

echo press enter to close or wait %worker_timeout% seconds
choice /c y /n /d y /t %worker_timeout% >nul
exit /b


:: function: convert HH:MM:SS,cc to centiseconds
:time_to_cs
for /f "tokens=1-4 delims=:,." %%a in ("%~1") do (
    set /a "%2=((1%%a-100)*3600 + (1%%b-100)*60 + (1%%c-100))*100 + (1%%d-100)"
)
exit /b
