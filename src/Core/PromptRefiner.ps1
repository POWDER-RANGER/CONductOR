<#
.SYNOPSIS
    Prompt refinement engine

.DESCRIPTION
    Optionally enhances user prompts for clarity and effectiveness
#>

class PromptRefiner {
    [object]$Logger
    [bool]$Enabled

    PromptRefiner([object]$logger, [bool]$enabled = $false) {
        $this.Logger = $logger
        $this.Enabled = $enabled
    }

    [string]Refine([string]$input) {
        if (-not $this.Enabled) {
            return $input
        }

        $this.Logger.Debug("Refining prompt")

        # Apply refinement rules
        $refined = $input

        # 1. Capitalize first letter
        if ($refined.Length -gt 0) {
            $refined = $refined.Substring(0,1).ToUpper() + $refined.Substring(1)
        }

        # 2. Add question mark if query starts with question word
        if ($refined -match '^(what|who|when|where|why|how|can|could|would|should|is|are|do|does)\s' -and $refined -notmatch '\?$') {
            $refined += '?'
        }

        # 3. Expand common abbreviations
        $abbreviations = @{
            ' pls '  = ' please '
            ' plz '  = ' please '
            ' thx '  = ' thanks '
            ' tho '  = ' though '
            ' w/'    = ' with '
            ' w/o '  = ' without '
            ' bc '   = ' because '
            ' btw '  = ' by the way '
            ' idk '  = ' I don\'t know '
            ' imo '  = ' in my opinion '
            ' async ' = ' asynchronous '
        }

        foreach ($abbr in $abbreviations.Keys) {
            $refined = $refined -replace [regex]::Escape($abbr), $abbreviations[$abbr]
        }

        # 4. Fix common typos
        $typos = @{
            'teh '   = 'the '
            'nad '   = 'and '
            'adn '   = 'and '
            'cna '   = 'can '
            'waht '  = 'what '
            'taht '  = 'that '
        }

        foreach ($typo in $typos.Keys) {
            $refined = $refined -replace $typo, $typos[$typo]
        }

        # 5. Ensure proper sentence structure for coding questions
        if ($refined -match '(write|create|make).*code' -and $refined -notmatch 'please') {
            $refined = "Please $($refined.ToLower())"
        }

        if ($refined -ne $input) {
            $this.Logger.Debug("Prompt refined: '$input' -> '$refined'")
        }

        return $refined
    }

    [hashtable]RefineWithApproval([string]$input) {
        $refined = $this.Refine($input)
        
        return @{
            Original = $input
            Refined  = $refined
            Changed  = ($input -ne $refined)
        }
    }

    [void]SetEnabled([bool]$enabled) {
        $this.Enabled = $enabled
        $this.Logger.Info("Prompt refinement: $enabled")
    }
}

Export-ModuleMember -Variable *