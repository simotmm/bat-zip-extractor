$chunksize = 100
$zips = get-childitem -filter *.zip | sort-object name
$total = $zips.count

if ($total -eq 0) {
    write-host "no .zip files found."
    exit
}

write-host "$total .zip files found."

$progressfile = join-path $pwd "progress.tmp"
"0" | set-content $progressfile

$chunks = [math]::ceiling($total / $chunksize)

for ($i = 0; $i -lt $chunks; $i++) {
    $start = $i * $chunksize
    $end   = [math]::min($start + $chunksize - 1, $total - 1)

    $files = $zips[$start..$end] | foreach-object { $_.fullname }

    write-host "starting worker $($i + 1): files $($start + 1) to $($end + 1)"

    start-process powershell -argumentlist @(
        "-noprofile",
        "-command",
        {
            param($files, $progressfile)

            foreach ($zip in $files) {
                $dest = [system.io.path]::getfilenamewithoutextension($zip)

                if (-not (test-path $dest)) {
                    new-item -itemtype directory -path $dest | out-null
                }

                expand-archive -path $zip -destinationpath $dest -force

                $mutex = new-object system.threading.mutex($false, "zipprogressmutex")
                $mutex.waitone()
                $current = [int](get-content $progressfile)
                ($current + 1) | set-content $progressfile
                $mutex.releasemutex()
            }
        },
        "-files", ($files -join "|"),
        "-progressfile", $progressfile
    )
}

do {
    start-sleep -milliseconds 300
    $done = [int](get-content $progressfile)

    write-progress `
        -activity "extracting zip files" `
        -status "$done / $total completed" `
        -percentcomplete (($done / $total) * 100)

} while ($done -lt $total)

remove-item $progressfile -force
write-progress -activity "extracting zip files" -completed
write-host "all zip files extracted successfully."
