<#
.SYNOPSIS
    Intent routing engine for CONductOR

.DESCRIPTION
    Analyzes user input to determine target service (PowerShell, ChatGPT, Claude, Perplexity).
    Uses pattern matching, explicit mentions, and keyword analysis.

.NOTES
    Issue: #2 - Intent Router Engine
#>

function Invoke-IntentRouter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Input
    )

    $result = [PSCustomObject]@{
        Target = 'Unknown'
        Confidence = 0
        Reason = ''
        OriginalInput = $Input
    }

    # Check for explicit service mentions (@chatgpt, @claude, @perplexity)
    if ($Input -match '@(chatgpt|gpt)') {
        $result.Target = 'ChatGPT'
        $result.Confidence = 100
        $result.Reason = 'Explicit @chatgpt mention'
        return $result
    }
    if ($Input -match '@claude') {
        $result.Target = 'Claude'
        $result.Confidence = 100
        $result.Reason = 'Explicit @claude mention'
        return $result
    }
    if ($Input -match '@(perplexity|pplx)') {
        $result.Target = 'Perplexity'
        $result.Confidence = 100
        $result.Reason = 'Explicit @perplexity mention'
        return $result
    }

    # PowerShell command detection (Verb-Noun pattern)
    if ($Input -match '^[A-Z][a-z]+-[A-Z][a-zA-Z]+') {
        $result.Target = 'PowerShell'
        $result.Confidence = 95
        $result.Reason = 'PowerShell cmdlet pattern detected'
        return $result
    }

    # PowerShell aliases and common commands
    $psCommands = @('ls', 'dir', 'cd', 'pwd', 'cat', 'rm', 'cp', 'mv', 'echo', 'where', 'select')
    $firstWord = ($Input -split '\s+')[0].ToLower()
    if ($psCommands -contains $firstWord) {
        $result.Target = 'PowerShell'
        $result.Confidence = 90
        $result.Reason = "PowerShell alias detected: $firstWord"
        return $result
    }

    # Research/factual queries → Perplexity
    $researchKeywords = @('what is', 'who is', 'when did', 'where is', 'how many', 'define', 'explain', 'research', 'find information', 'latest news')
    foreach ($keyword in $researchKeywords) {
        if ($Input -match $keyword) {
            $result.Target = 'Perplexity'
            $result.Confidence = 85
            $result.Reason = "Research query detected: '$keyword'"
            return $result
        }
    }

    # Coding/technical queries → ChatGPT
    $codingKeywords = @('write code', 'function', 'script', 'debug', 'error', 'implement', 'algorithm', 'regex', 'sql', 'api')
    foreach ($keyword in $codingKeywords) {
        if ($Input -match $keyword) {
            $result.Target = 'ChatGPT'
            $result.Confidence = 80
            $result.Reason = "Coding query detected: '$keyword'"
            return $result
        }
    }

    # Creative/writing tasks → Claude
    $creativeKeywords = @('write', 'compose', 'draft', 'edit', 'story', 'essay', 'poem', 'creative', 'brainstorm')
    foreach ($keyword in $creativeKeywords) {
        if ($Input -match $keyword) {
            $result.Target = 'Claude'
            $result.Confidence = 75
            $result.Reason = "Creative task detected: '$keyword'"
            return $result
        }
    }

    # Default: ChatGPT for general queries
    $result.Target = 'ChatGPT'
    $result.Confidence = 50
    $result.Reason = 'Default routing for general query'
    return $result
}

Export-ModuleMember -Function Invoke-IntentRouter
