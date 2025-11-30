<#
.SYNOPSIS
    Configuration manager for CONductOR

.DESCRIPTION
    Handles loading, saving, and managing configuration settings
#>

class ConfigManager {
    [string]$ConfigPath
    [hashtable]$Config
    [object]$Logger

    ConfigManager([string]$configPath, [object]$logger) {
        $this.ConfigPath = $configPath
        $this.Logger = $logger
        $this.LoadConfig()
    }

    [void]LoadConfig() {
        try {
            if (Test-Path $this.ConfigPath) {
                $this.Logger.Info("Loading configuration from: $($this.ConfigPath)")
                $content = Get-Content $this.ConfigPath -Raw
                $this.Config = $content | ConvertFrom-Json -AsHashtable
            } else {
                $this.Logger.Info("No config file found, using defaults")
                $this.Config = $this.GetDefaultConfig()
                $this.SaveConfig()
            }
        }
        catch {
            $this.Logger.Warn("Failed to load config: $($_.Exception.Message). Using defaults.")
            $this.Config = $this.GetDefaultConfig()
        }
    }

    [hashtable]GetDefaultConfig() {
        return @{
            Browser = @{
                ProfilePath = ""
                Timeout     = 30
                Headless    = $false
            }
            Execution = @{
                SafeMode           = $true
                MaxExecutionTime   = 300
                AllowDangerousOps  = $false
            }
            PromptRefinement = @{
                Enabled        = $false
                AutoApprove    = $false
            }
            Services = @{
                ChatGPT = @{
                    Enabled  = $true
                    Priority = 1
                }
                Claude = @{
                    Enabled  = $true
                    Priority = 2
                }
                Perplexity = @{
                    Enabled  = $true
                    Priority = 3
                }
            }
            Logging = @{
                Level       = 'Info'
                LogToFile   = $true
                LogPath     = './logs/conductor.log'
                MaxLogSize  = 10485760  # 10MB
            }
            UI = @{
                Theme           = 'Dark'
                FontSize        = 12
                WindowWidth     = 800
                WindowHeight    = 600
                ShowTimestamps  = $true
            }
        }
    }

    [void]SaveConfig() {
        try {
            $configDir = Split-Path $this.ConfigPath
            if ($configDir -and -not (Test-Path $configDir)) {
                New-Item -ItemType Directory -Path $configDir -Force | Out-Null
            }

            $this.Config | ConvertTo-Json -Depth 10 | Set-Content $this.ConfigPath
            $this.Logger.Info("Configuration saved")
        }
        catch {
            $this.Logger.Error("Failed to save config: $($_.Exception.Message)")
        }
    }

    [object]Get([string]$key) {
        $keys = $key -split '\.'
        $current = $this.Config

        foreach ($k in $keys) {
            if ($current.ContainsKey($k)) {
                $current = $current[$k]
            } else {
                $this.Logger.Warn("Config key not found: $key")
                return $null
            }
        }

        return $current
    }

    [void]Set([string]$key, [object]$value) {
        $keys = $key -split '\.'
        $current = $this.Config

        for ($i = 0; $i -lt $keys.Length - 1; $i++) {
            if (-not $current.ContainsKey($keys[$i])) {
                $current[$keys[$i]] = @{}
            }
            $current = $current[$keys[$i]]
        }

        $current[$keys[-1]] = $value
        $this.Logger.Debug("Config updated: $key = $value")
    }

    [void]Reset() {
        $this.Config = $this.GetDefaultConfig()
        $this.SaveConfig()
        $this.Logger.Info("Configuration reset to defaults")
    }
}

Export-ModuleMember -Variable *