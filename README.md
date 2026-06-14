# Windows 10 ESU Activation

PowerShell scripts to remotely apply Windows 10 Extended Security Update (ESU) licensing across multiple machines using slmgr.vbs. Includes both sequential and parallel execution versions.

## Background

Windows 10 reached End of Support in October 2025. These scripts were created to apply ESU 
licensing across domain-joined machines remotely, using `slmgr.vbs` to install the product 
key, activate it, and capture license info - all in parallel with results logged to a text file.

- [Windows 10 Extended Security Updates overview](https://learn.microsoft.com/en-us/windows/whats-new/extended-security-updates)
- [How to enable Extended Security Updates](https://learn.microsoft.com/en-us/windows/whats-new/enable-extended-security-updates)

## Scripts

| Script | Purpose |
|---|---|
| `esu-activation-parallel.ps1` | Runs activation commands across all machines in parallel. Requires PowerShell 7+. |
| `esu-activation.ps1` | Runs activation commands sequentially. Compatible with PowerShell 5.1+. |

## Requirements

- WinRM enabled on target machines
- A valid Windows 10 ESU product key and Activation ID from Microsoft
- PowerShell 5.1+ for the sequential version
- PowerShell 7+ for the parallel version (uses `ForEach-Object -Parallel`)

## Usage

1. Populate `computers.csv` with a `ComputerName` column listing target hostnames
2. Update the script with your ESU product key and Activation ID:
```powershell
    /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX        # your ESU product key
    /ato XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX # your Activation ID
```
3. Update `$computerList` and `$outputTxt` paths to match your environment
4. Run the script - results are written to the output file grouped by computer name

## Output

Results are saved to a timestamped `.txt` file with each machine's `slmgr /dlv` output or 
error details if the connection failed.

## Notes

- Scripts sanitized for public sharing. Originally written for use in a managed enterprise environment.
- Default throttle limit is 15 parallel jobs - adjust `$throttleLimit` as needed
- Product key and Activation ID are redacted - substitute your own licensed values from Microsoft
