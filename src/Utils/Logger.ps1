<#
.SYNOPSIS
    Logging utility for CONductOR

.DESCRIPTION
    Provides structured logging with multiple levels and optional file output
#>

class Logger {
    [string]$LogPath
    [string]$Level
    [bool]$LogToFile
    [int]$MaxLogSize
    
    # Log level hierarchy
    hidden [hashtable]$LevelPriority = @{
        'Debug' = 0
        'Info'  = 1
        'Warn'  = 2
        'Error' = 3
    }

    Logger([string]$level = 'Info', [bool]$logToFile = $true, [string]$logPath = './logs/conductor.log') {
        $this.Level = $level
        $this.LogToFile = $logToFile
        $this.LogPath = $logPath
        $this.MaxLogSize = 10485760  # 10MB
        $this.InitializeLogFile()
    }

    [void]InitializeLogFile() {
        if ($this.LogToFile) {
            $logDir = Split-Path $this.LogPath
            if ($logDir -and -not (Test-Path $logDir)) {
                New-Item -ItemType Directory -Path $logDir -Force | Out-Null
            }

            # Rotate log if too large
            if ((Test-Path $this.LogPath) -and (Get-Item $this.LogPath).Length -gt $this.MaxLogSize) {
                $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
                $archivePath = $this.LogPath -replace '\.log$', "_$timestamp.log"
                Move-Item $this.LogPath $archivePath -Force
            }
        }
    }

    [void]Log([string]$level, [string]$message) {
        # Check if this message should be logged based on level
        if ($this.LevelPriority[$level] -lt $this.LevelPriority[$this.Level]) {
            return
        }

        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $logEntry = "[$timestamp] [$level] $message"

        # Console output with color
        $color = switch ($level) {
            'Debug' { 'Gray' }
            'Info'  { 'White' }
            'Warn'  { 'Yellow' }
            'Error' { 'Red' }
            default { 'White' }
        }

        Write-Host $logEntry -ForegroundColor $color

        # File output
        if ($this.LogToFile) {
            try {
                Add-Content -Path $this.LogPath -Value $logEntry
            }
            catch {
                Write-Warning "Failed to write to log file: $($_.Exception.Message)"
            }
        }
    }

    [void]Debug([string]$message) {
        $this.Log('Debug', $message)
    }

    [void]Info([string]$message) {
        $this.Log('Info', $message)
    }

    [void]Warn([string]$message) {
        $this.Log('Warn', $message)
    }

    [void]Error([string]$message) {
        $this.Log('Error', $message)
    }

    [void]SetLevel([string]$level) {
        if ($this.LevelPriority.ContainsKey($level)) {
            $this.Level = $level
            $this.Info("Log level set to: $level")
        } else {
            $this.Warn("Invalid log level: $level")
        }
    }
}

Export-ModuleMember -Variable *