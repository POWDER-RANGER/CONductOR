<#
.SYNOPSIS
    Intent routing engine for CONductOR

.DESCRIPTION
    Analyzes user input and routes to appropriate handler:
    - Local PowerShell commands
    - ChatGPT queries
    - Claude queries
    - Perplexity research queries
#>

class IntentRouter {
    [hashtable]$ServicePrefixes
    [hashtable]$CommandPatterns
    [object]$Logger

    IntentRouter([object]$logger) {
        $this.Logger = $logger
        $this.ServicePrefixes = @{
            '@chatgpt'    = 'ChatGPT'
            '@claude'     = 'Claude'
            '@perplexity' = 'Perplexity'
            '@local'      = 'PowerShell'
        }
        $this.InitializePatterns()
    }

    [void]InitializePatterns() {
        # PowerShell command patterns
        $this.CommandPatterns = @{
            PowerShell = @(
                '^Get-',
                '^Set-',
                '^New-',
                '^Remove-',
                '^Test-',
                '^Start-',
                '^Stop-',
                '^Invoke-',
                '\|\s*(?:Where|Select|ForEach|Sort)',
                '^\$\w+\s*=',
                '^cd\s+',
                '^ls\s*',
                '^dir\s*',
                'Get-ChildItem',
                'Get-Process',
                'Get-Service'
            )
            Research = @(
                '^(what|who|when|where|why|how)\s+(?:is|are|was|were|did|does)',
                'latest news',
                'research',
                'find information',
                'look up',
                'search for'
            )
            Code = @(
                'write.*(?:script|function|code)',
                'create.*(?:script|function|class)',
                'debug',
                'fix.*(?:code|script|error)',
                'refactor',
                'optimize'
            )
        }
    }

    [string]Route([string]$input) {
        $this.Logger.Info("Routing input: $($input.Substring(0, [Math]::Min(50, $input.Length)))...")

        # Check for explicit service prefix
        foreach ($prefix in $this.ServicePrefixes.Keys) {
            if ($input -match "^$prefix\s+") {
                $service = $this.ServicePrefixes[$prefix]
                $this.Logger.Info("Explicit routing to: $service")
                return $service
            }
        }

        # Pattern-based routing
        # 1. Check PowerShell commands first (highest priority)
        foreach ($pattern in $this.CommandPatterns['PowerShell']) {
            if ($input -match $pattern) {
                $this.Logger.Info("PowerShell command detected")
                return 'PowerShell'
            }
        }

        # 2. Check research patterns
        foreach ($pattern in $this.CommandPatterns['Research']) {
            if ($input -match $pattern) {
                $this.Logger.Info("Research query detected -> Perplexity")
                return 'Perplexity'
            }
        }

        # 3. Check code patterns
        foreach ($pattern in $this.CommandPatterns['Code']) {
            if ($input -match $pattern) {
                $this.Logger.Info("Code request detected -> Claude")
                return 'Claude'
            }
        }

        # Default to ChatGPT for general queries
        $this.Logger.Info("Default routing -> ChatGPT")
        return 'ChatGPT'
    }

    [hashtable]GetRoutingInfo([string]$input) {
        $service = $this.Route($input)
        $cleanedInput = $input

        # Remove service prefix if present
        foreach ($prefix in $this.ServicePrefixes.Keys) {
            if ($input -match "^$prefix\s+(.+)$") {
                $cleanedInput = $matches[1]
                break
            }
        }

        return @{
            Service      = $service
            OriginalInput = $input
            CleanedInput  = $cleanedInput
            Confidence    = $this.CalculateConfidence($input, $service)
        }
    }

    [int]CalculateConfidence([string]$input, [string]$service) {
        # Simple confidence scoring (0-100)
        if ($input -match '^@\w+\s+') {
            return 100  # Explicit prefix = 100% confidence
        }

        $matchCount = 0
        $patterns = @()

        switch ($service) {
            'PowerShell' { $patterns = $this.CommandPatterns['PowerShell'] }
            'Perplexity' { $patterns = $this.CommandPatterns['Research'] }
            'Claude'     { $patterns = $this.CommandPatterns['Code'] }
            default      { return 50 }  # Default confidence
        }

        foreach ($pattern in $patterns) {
            if ($input -match $pattern) {
                $matchCount++
            }
        }

        return [Math]::Min(100, 50 + ($matchCount * 25))
    }
}

Export-ModuleMember -Variable *