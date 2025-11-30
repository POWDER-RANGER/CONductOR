<#
.SYNOPSIS
    CONductOR - Windows-native AI orchestration assistant entry point

.DESCRIPTION
    Launches the CONductOR assistant with WPF chat interface and multi-service routing.
    Routes user input to PowerShell execution, ChatGPT, Claude, or Perplexity.

.EXAMPLE
    .\Start-Assistant.ps1
    Launches the CONductOR chat interface

.NOTES
    Author: POWDER-RANGER
    Repository: https://github.com/POWDER-RANGER/CONductOR
    License: MIT
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Debug
)

# Set strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Import required modules
$ModulePath = Join-Path $PSScriptRoot 'Core'
Import-Module (Join-Path $ModulePath 'IntentRouter.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'UI' 'ChatWindow.ps1') -Force

# Display banner
Write-Host "`n" -ForegroundColor Cyan
Write-Host "  ██████╗ ██████╗ ███╗   ██╗██████╗ ██╗   ██╗ ██████╗████████╗ ██████╗ ██████╗" -ForegroundColor Cyan
Write-Host " ██╔════╝██╔═══██╗████╗  ██║██╔══██╗██║   ██║██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗" -ForegroundColor Cyan
Write-Host " ██║     ██║   ██║██╔██╗ ██║██║  ██║██║   ██║██║        ██║   ██║   ██║██████╔╝" -ForegroundColor Cyan
Write-Host " ██║     ██║   ██║██║╚██╗██║██║  ██║██║   ██║██║        ██║   ██║   ██║██╔══██╗" -ForegroundColor Cyan
Write-Host " ╚██████╗╚██████╔╝██║ ╚████║██████╔╝╚██████╔╝╚██████╗   ██║   ╚██████╔╝██║  ██║" -ForegroundColor Cyan
Write-Host "  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝" -ForegroundColor Cyan
Write-Host "`n  Windows-native AI Orchestration Assistant" -ForegroundColor Gray
Write-Host "  Multi-service chat | Browser automation | PowerShell control`n" -ForegroundColor Gray

try {
    # Launch the WPF chat window
    Write-Host "[INFO] Launching CONductOR chat interface..." -ForegroundColor Green
    Start-ChatWindow -Debug:$Debug
}
catch {
    Write-Host "[ERROR] Failed to start CONductOR: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
