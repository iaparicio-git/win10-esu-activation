# --- Runs ESU patching commands on list of machines remotely --- #

# Set paths for computer list and output files
$computerList = "C:\Scripts\ESU\computers.csv"
$outputTxt    = "C:\Scripts\ESU\slmgr-results.txt"

# Import computer list - start column in CSV with 'ComputerName'
$computers = Import-Csv -Path $computerList

foreach ($entry in $computers) {
    $computer = $entry.ComputerName
    Write-Host "Connecting to $computer..." -ForegroundColor Green

    try {
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
            $output = @()

            # Install product key
            $output += "---- Running /ipk ----"
            $output += cscript.exe //NoLogo "$env:windir\system32\slmgr.vbs" /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
            $output += ""

            # Activate key
            $output += "---- Running /ato ----"
            $output += cscript.exe //NoLogo "$env:windir\system32\slmgr.vbs" /ato XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
            $output += ""

            # Display license info
            $output += "---- Running /dlv ----"
            $output += cscript.exe //NoLogo "$env:windir\system32\slmgr.vbs" /dlv
            $output
        } -ErrorAction Stop
        
        # Append results to text file
        Add-Content -Path $outputTxt -Value "==============================="
        Add-Content -Path $outputTxt -Value "Computer: $computer"
        Add-Content -Path $outputTxt -Value "Timestamp: $(Get-Date)"
        Add-Content -Path $outputTxt -Value "==============================="
        Add-Content -Path $outputTxt -Value ($results -join "`n")
        Add-Content -Path $outputTxt -Value "`n`n"
        
        Write-Host "Output appended for $computer" -ForegroundColor Cyan
    }
    catch {
        Add-Content -Path $outputTxt -Value "==============================="
        Add-Content -Path $outputTxt -Value "Computer: $computer"
        Add-Content -Path $outputTxt -Value "Timestamp: $(Get-Date)"
        Add-Content -Path $outputTxt -Value "ERROR connecting to $computer"
        Add-Content -Path $outputTxt -Value ($_ | Out-String)
        Add-Content -Path $outputTxt -Value "`n`n"

        Write-Host "Error connecting to $computer — logged in output file" -ForegroundColor Red
    }
}
