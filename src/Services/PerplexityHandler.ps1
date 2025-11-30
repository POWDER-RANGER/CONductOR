<#
.SYNOPSIS
    Perplexity AI service handler

.DESCRIPTION
    Handles interaction with Perplexity through browser automation
#>

class PerplexityHandler {
    [object]$Browser
    [object]$Logger
    [string]$BaseUrl = 'https://www.perplexity.ai'

    PerplexityHandler([object]$browser, [object]$logger) {
        $this.Browser = $browser
        $this.Logger = $logger
    }

    [string]SendQuery([string]$query) {
        try {
            $this.Logger.Info("Sending query to Perplexity")
            
            # Navigate to Perplexity
            $this.Browser.NavigateTo($this.BaseUrl)
            Start-Sleep -Seconds 3

            # Find the search/input field
            $inputSelector = 'textarea[placeholder*="Ask"], input[type="text"]'
            $this.Browser.WaitForElement($inputSelector, 10)

            # Send the query
            $this.Browser.SendKeys($inputSelector, $query)
            Start-Sleep -Milliseconds 500

            # Submit
            $element = $this.Browser.FindElement($inputSelector)
            if ($element) {
                $element.SendKeys([OpenQA.Selenium.Keys]::Enter)
            }

            # Wait for response and sources to load
            Start-Sleep -Seconds 4
            $this.WaitForResponse()

            # Extract response with sources
            $response = $this.ExtractResponseWithSources()
            $this.Logger.Info("Received Perplexity response with sources")
            
            return $response
        }
        catch {
            $this.Logger.Error("Perplexity query failed: $($_.Exception.Message)")
            return "Error: Failed to get Perplexity response - $($_.Exception.Message)"
        }
    }

    [void]WaitForResponse() {
        # Perplexity shows sources while generating
        $maxWait = 60
        $elapsed = 0
        
        while ($elapsed -lt $maxWait) {
            # Look for completion indicators
            # Perplexity usually shows "Related" section when done
            $relatedSection = $this.Browser.FindElement('div:contains("Related")')
            if ($relatedSection) {
                break
            }
            
            Start-Sleep -Seconds 1
            $elapsed++
        }
        
        Start-Sleep -Seconds 2  # Extra time for source cards to render
    }

    [string]ExtractResponseWithSources() {
        try {
            $output = ""
            
            # Extract main answer
            $answerSelector = 'div[class*="answer"], div[class*="response"]'
            $answerElement = $this.Browser.FindElement($answerSelector)
            
            if ($answerElement) {
                $output += "ANSWER:`n$($answerElement.Text)`n`n"
            }
            
            # Extract sources
            $sourceElements = $this.Browser.Driver.FindElements([OpenQA.Selenium.By]::CssSelector('a[class*="source"], cite'))
            
            if ($sourceElements.Count -gt 0) {
                $output += "SOURCES:`n"
                $sourceNum = 1
                foreach ($source in $sourceElements) {
                    $output += "[$sourceNum] $($source.Text) - $($source.GetAttribute('href'))`n"
                    $sourceNum++
                }
            }
            
            if ($output -eq "") {
                # Fallback to page text
                $output = $this.Browser.GetPageText()
            }
            
            return $output
        }
        catch {
            $this.Logger.Warn("Could not extract structured response, returning page text")
            return $this.Browser.GetPageText()
        }
    }

    [bool]IsAvailable() {
        try {
            $this.Browser.NavigateTo($this.BaseUrl)
            Start-Sleep -Seconds 2
            
            # Check if we can find the search input
            $input = $this.Browser.FindElement('textarea, input[type="text"]')
            return $null -ne $input
        }
        catch {
            return $false
        }
    }
}

Export-ModuleMember -Variable *