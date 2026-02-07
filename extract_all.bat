@echo off
setlocal EnableDelayedExpansion
echo automatic extraction of .zip files in the current folder.
set nzipfiles=0
for %%F in (*.zip) do (
    set /a nzipfiles+=1
)
if %nzipfiles% EQU 0 (
    echo no .zip files found, nothing to extract.
) else (
    echo %nzipfiles% .zip files found.
    echo extraction in progress:
    set count=0
    for %%F in (*.zip) do (
        set /a count+=1
        echo extracting file !count!: '%%F' -^> folder '%%~nF'
        if not exist "%%~nF" mkdir "%%~nF"
        tar -xf "%%F" -C "%%~nF"
    )
    echo operation completed successfully, !count! .zip files extracted.
)
pause
