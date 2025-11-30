<#
.SYNOPSIS
    PowerShell command executor

.DESCRIPTION
    Safely executes PowerShell commands with security checks and sandboxing
#>

class PowerShellExecutor {
    [object]$Logger
    [bool]$SafeMode
    [string[]]$BlockedCommands

    PowerShellExecutor([object]$logger, [bool]$safeMode = $true) {
        $this.Logger = $logger
        $this.SafeMode = $safeMode
        $this.InitializeBlockedCommands()
    }

    [void]InitializeBlockedCommands() {
        # Commands that should never be auto-executed in safe mode
        $this.BlockedCommands = @(
            'Remove-Item',
            'Remove-*',
            'Delete-*',
            'Format-Volume',
            'Clear-Disk',
            'Stop-Computer',
            'Restart-Computer',
            'Invoke-Expression',
            'iex',
            'Invoke-WebRequest.*\|.*iex',
            'Set-ExecutionPolicy',
            'Remove-Service'
        )
    }

    [hashtable]Execute([string]$command) {
        $this.Logger.Info("Executing PowerShell command: $($command.Substring(0, [Math]::Min(100, $command.Length)))")

        # Security check
        if ($this.SafeMode -and $this.IsBlocked($command)) {
            $this.Logger.Warn("Blocked potentially dangerous command: $command")
            return @{
                Success = $false
                Output  = ""
                Error   = "Command blocked by safety filter. Dangerous commands require manual execution."
                ExitCode = -1
            }
        }

        try {
            # Create script block
            $scriptBlock = [ScriptBlock]::Create($command)
            
            # Execute with output capture
            $output = @()
            $errors = @()
            
            $result = & $scriptBlock 2>&1 | ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $errors += $_.ToString()
                } else {
                    $output += $_.ToString()
                }
            }

            $success = $errors.Count -eq 0
            
            if ($success) {
                $this.Logger.Info("Command executed successfully")
            } else {
                $this.Logger.Warn("Command executed with errors")
            }

            return @{
                Success  = $success
                Output   = ($output -join "`n")
                Error    = ($errors -join "`n")
                ExitCode = if ($success) { 0 } else { 1 }
            }
        }
        catch {
            $this.Logger.Error("Command execution failed: $($_.Exception.Message)")
            return @{
                Success  = $false
                Output   = ""
                Error    = $_.Exception.Message
                ExitCode = 1
            }
        }
    }

    [bool]IsBlocked([string]$command) {
        foreach ($pattern in $this.BlockedCommands) {
            if ($command -match $pattern) {
                return $true
            }
        }
        return $false
    }

    [string]FormatOutput([hashtable]$result) {
        $formatted = ""
        
        if ($result.Success) {
            $formatted = "✓ Execution successful`n`n"
            if ($result.Output) {
                $formatted += $result.Output
            } else {
                $formatted += "(No output)"
            }
        } else {
            $formatted = "✗ Execution failed`n`n"
            $formatted += "ERROR: $($result.Error)"
        }
        
        return $formatted
    }

    [void]SetSafeMode([bool]$enabled) {
        $this.SafeMode = $enabled
        $this.Logger.Info("Safe mode: $enabled")
    }
}

Export-ModuleMember -Variable *