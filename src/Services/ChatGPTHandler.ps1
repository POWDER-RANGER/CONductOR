<#
.SYNOPSIS
    ChatGPT service handler

.DESCRIPTION
    Handles interaction with ChatGPT through browser automation
#>

class ChatGPTHandler {
    [object]$Browser
    [object]$Logger
    [string]$BaseUrl = 'https://chat.openai.com'

    ChatGPTHandler([object]$browser, [object]$logger) {
        $this.Browser = $browser
        $this.Logger = $logger
    }

    [string]SendQuery([string]$query) {
        try {
            $this.Logger.Info("Sending query to ChatGPT")
            
            # Navigate to ChatGPT
            $this.Browser.NavigateTo($this.BaseUrl)
            Start-Sleep -Seconds 3

            # Wait for and find the input textarea
            # ChatGPT uses a contenteditable div or textarea
            $inputSelector = 'textarea[placeholder*="Message"], div[contenteditable="true"]'
            $this.Browser.WaitForElement($inputSelector, 10)

            # Send the query
            $this.Browser.SendKeys($inputSelector, $query)
            Start-Sleep -Milliseconds 500

            # Submit (usually Enter key or a button)
            # Try Enter key first
            $element = $this.Browser.FindElement($inputSelector)
            if ($element) {
                $element.SendKeys([OpenQA.Selenium.Keys]::Enter)
            }

            # Wait for response (look for streaming completion indicators)
            Start-Sleep -Seconds 3
            $this.WaitForResponse()

            # Extract response text
            $response = $this.ExtractLatestResponse()
            $this.Logger.Info("Received ChatGPT response (${$response.Length} chars)")
            
            return $response
        }
        catch {
            $this.Logger.Error("ChatGPT query failed: $($_.Exception.Message)")
            return "Error: Failed to get ChatGPT response - $($_.Exception.Message)"
        }
    }

    [void]WaitForResponse() {
        # Wait for response generation to complete
        # Look for stop button disappearing or regenerate button appearing
        $maxWait = 60  # seconds
        $elapsed = 0
        
        while ($elapsed -lt $maxWait) {
            # Check if response is still being generated
            $stopButton = $this.Browser.FindElement('button[aria-label*="Stop"]')
            if (-not $stopButton) {
                # Response complete
                break
            }
            Start-Sleep -Seconds 1
            $elapsed++
        }
    }

    [string]ExtractLatestResponse() {
        try {
            # ChatGPT responses are in specific div structures
            # This selector may need adjustment based on UI updates
            $responseSelector = 'div[data-message-author-role="assistant"]:last-of-type'
            $responseElement = $this.Browser.FindElement($responseSelector)
            
            if ($responseElement) {
                return $responseElement.Text
            }
            
            # Fallback: get all visible text
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
            
            # Check if we can find the input field (indicates logged in)
            $input = $this.Browser.FindElement('textarea')
            return $null -ne $input
        }
        catch {
            return $false
        }
    }
}

Export-ModuleMember -Variable *