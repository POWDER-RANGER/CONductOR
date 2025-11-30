<#
.SYNOPSIS
    Claude (Anthropic) service handler

.DESCRIPTION
    Handles interaction with Claude through browser automation
#>

class ClaudeHandler {
    [object]$Browser
    [object]$Logger
    [string]$BaseUrl = 'https://claude.ai'

    ClaudeHandler([object]$browser, [object]$logger) {
        $this.Browser = $browser
        $this.Logger = $logger
    }

    [string]SendQuery([string]$query) {
        try {
            $this.Logger.Info("Sending query to Claude")
            
            # Navigate to Claude
            $this.Browser.NavigateTo("$($this.BaseUrl)/new")
            Start-Sleep -Seconds 3

            # Find the input field
            # Claude typically uses a contenteditable div or textarea
            $inputSelector = 'div[contenteditable="true"], textarea'
            $this.Browser.WaitForElement($inputSelector, 10)

            # Send the query
            $this.Browser.SendKeys($inputSelector, $query)
            Start-Sleep -Milliseconds 500

            # Submit (usually Enter key or send button)
            $element = $this.Browser.FindElement($inputSelector)
            if ($element) {
                # Try Ctrl+Enter for Claude
                $element.SendKeys([OpenQA.Selenium.Keys]::Control + [OpenQA.Selenium.Keys]::Enter)
            }

            # Alternative: look for send button
            $sendButton = $this.Browser.FindElement('button[aria-label*="Send"]')
            if ($sendButton) {
                $sendButton.Click()
            }

            # Wait for response
            Start-Sleep -Seconds 3
            $this.WaitForResponse()

            # Extract response
            $response = $this.ExtractLatestResponse()
            $this.Logger.Info("Received Claude response (${$response.Length} chars)")
            
            return $response
        }
        catch {
            $this.Logger.Error("Claude query failed: $($_.Exception.Message)")
            return "Error: Failed to get Claude response - $($_.Exception.Message)"
        }
    }

    [void]WaitForResponse() {
        # Wait for Claude's response to complete
        $maxWait = 60  # seconds
        $elapsed = 0
        
        while ($elapsed -lt $maxWait) {
            # Check if still generating (look for stop button or loading indicator)
            $stopButton = $this.Browser.FindElement('button[aria-label*="Stop"]')
            if (-not $stopButton) {
                break
            }
            Start-Sleep -Seconds 1
            $elapsed++
        }
        
        # Additional wait for rendering
        Start-Sleep -Seconds 2
    }

    [string]ExtractLatestResponse() {
        try {
            # Claude's response structure (adjust selector as needed)
            # Look for the assistant's message container
            $responseSelector = 'div[data-test-render-count], div.font-claude-message'
            $responseElement = $this.Browser.FindElement($responseSelector)
            
            if ($responseElement) {
                return $responseElement.Text
            }
            
            # Fallback
            return $this.Browser.GetPageText()
        }
        catch {
            $this.Logger.Warn("Could not extract specific response, returning page text")
            return $this.Browser.GetPageText()
        }
    }

    [bool]IsAvailable() {
        try {
            $this.Browser.NavigateTo($this.BaseUrl)
            Start-Sleep -Seconds 2
            
            # Check if we can access Claude (logged in)
            $pageText = $this.Browser.GetPageText()
            return $pageText -notmatch 'Sign in'
        }
        catch {
            return $false
        }
    }
}

Export-ModuleMember -Variable *