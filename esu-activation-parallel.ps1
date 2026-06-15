# --- Runs ESU patching commands on list of machines remotely --- #

# Captures date for output file creation
$dateRan = Get-Date -Format "yyyyMMdd-HHmmss"

# Sets throttle limit for parallel execution
$throttleLimit = 15

# Set paths for computer list and output files
$computerList = "C:\Scripts\ESU\computers.csv"
$outputTxt    = "C:\Scripts\ESU\slmgr-results-$($dateRan).txt"

# Import computer list - start column in CSV with 'ComputerName'
$computers = Import-Csv -Path $computerList | Select-Object -ExpandProperty ComputerName

# runs parallel jobs and stores results
$results = $computers | ForEach-Object -Parallel {
    param($outputTxt)
    $computer = $_
    Write-Host "Connecting to $computer..." -ForegroundColor Green

    try {
        $output = Invoke-Command -ComputerName $computer -ScriptBlock {
            $lines = @()

            # Install product key
            $lines += "---- Running /ipk ----"
            $lines += cscript.exe //NoLogo "$env:windir\system32\slmgr.vbs" /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
            $lines += ""

            # Activate key with the appropriate Activation ID
            $lines += "---- Running /ato ----"
            $lines += cscript.exe //NoLogo "$env:windir\system32\slmgr.vbs" /ato XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
            $lines += ""

            # Display license info
            $lines += "---- Running /dlv ----"
            $lines += cscript.exe //NoLogo "$env:windir\system32\slmgr.vbs" /dlv
            $lines -join "`n"
        } -ErrorAction Stop
        
        [PSCustomObject]@{
            Computer  = $computer
            TimeStamp = Get-Date -Format "MM/dd/yyyy hh:mm:ss tt"
            Output    = $output 
            Error     = $null
        }
    }
    catch {
        [PSCustomObject]@{
            Computer  = $computer
            TimeStamp = Get-Date
            Output    = $null 
            Error     = $_ | Out-String
        }
    }
} -ThrottleLimit $throttleLimit

# sort results by computer name
$sorted = $results | Sort-Object Computer

# write output to file in ascending order by computer name
foreach($r in $sorted) {
    Add-Content -Path $outputTxt -Value "==============================="
    Add-Content -Path $outputTxt -Value "Computer: $($r.Computer)"
    Add-Content -Path $outputTxt -Value "TimeStamp: $($r.TimeStamp)"
    Add-Content -Path $outputTxt -Value "==============================="

    if($r.Error) {
        Add-Content -Path $outputTxt -Value "ERROR connecting to $($r.Computer)"
        Add-Content -Path $outputTxt -Value $r.Error
    } else {
        Add-Content -Path $outputTxt -Value $r.Output
    }

    Add-Content -Path $outputTxt -Value "`n"
}

Write-Host "`nResults saved to: $outputTxt" -ForegroundColor Green
