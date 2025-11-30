<#
.SYNOPSIS
    Browser automation controller using Selenium

.DESCRIPTION
    Manages Edge browser instances for AI service interaction
    Provides transparent, visible automation
#>

class BrowserController {
    [object]$Driver
    [string]$ProfilePath
    [object]$Logger
    [bool]$IsInitialized

    BrowserController([string]$profilePath, [object]$logger) {
        $this.ProfilePath = $profilePath
        $this.Logger = $logger
        $this.IsInitialized = $false
    }

    [void]Initialize() {
        try {
            $this.Logger.Info("Initializing browser controller...")
            
            # Check if Selenium module is available
            if (-not (Get-Module -ListAvailable -Name Selenium)) {
                throw "Selenium module not found. Install with: Install-Module Selenium -Scope CurrentUser"
            }

            Import-Module Selenium -ErrorAction Stop

            # Configure Edge options
            $edgeOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
            
            # Use default profile if no custom path specified
            if ($this.ProfilePath) {
                $edgeOptions.AddArgument("user-data-dir=$($this.ProfilePath)")
            }

            # Additional options for better automation
            $edgeOptions.AddArgument('--start-maximized')
            $edgeOptions.AddArgument('--disable-blink-features=AutomationControlled')
            $edgeOptions.AddExcludedArgument('enable-automation')
            $edgeOptions.AddAdditionalOption('useAutomationExtension', $false)

            # Initialize Edge driver
            $this.Driver = New-Object OpenQA.Selenium.Edge.EdgeDriver($edgeOptions)
            $this.IsInitialized = $true
            
            $this.Logger.Info("Browser controller initialized successfully")
        }
        catch {
            $this.Logger.Error("Failed to initialize browser: $($_.Exception.Message)")
            throw
        }
    }

    [void]NavigateTo([string]$url) {
        if (-not $this.IsInitialized) {
            $this.Initialize()
        }

        try {
            $this.Logger.Info("Navigating to: $url")
            $this.Driver.Navigate().GoToUrl($url)
            Start-Sleep -Seconds 2  # Wait for page load
        }
        catch {
            $this.Logger.Error("Navigation failed: $($_.Exception.Message)")
            throw
        }
    }

    [object]FindElement([string]$selector, [string]$by = 'CssSelector') {
        try {
            switch ($by) {
                'CssSelector' { 
                    return $this.Driver.FindElement([OpenQA.Selenium.By]::CssSelector($selector)) 
                }
                'XPath' { 
                    return $this.Driver.FindElement([OpenQA.Selenium.By]::XPath($selector)) 
                }
                'Id' { 
                    return $this.Driver.FindElement([OpenQA.Selenium.By]::Id($selector)) 
                }
                default { 
                    throw "Unknown selector type: $by" 
                }
            }
        }
        catch {
            $this.Logger.Warn("Element not found: $selector")
            return $null
        }
    }

    [void]SendKeys([string]$selector, [string]$text, [string]$by = 'CssSelector') {
        $element = $this.FindElement($selector, $by)
        if ($element) {
            $element.Clear()
            $element.SendKeys($text)
            $this.Logger.Debug("Sent keys to element: $selector")
        }
    }

    [void]Click([string]$selector, [string]$by = 'CssSelector') {
        $element = $this.FindElement($selector, $by)
        if ($element) {
            $element.Click()
            $this.Logger.Debug("Clicked element: $selector")
        }
    }

    [string]GetPageText() {
        try {
            return $this.Driver.FindElement([OpenQA.Selenium.By]::TagName('body')).Text
        }
        catch {
            $this.Logger.Error("Failed to get page text: $($_.Exception.Message)")
            return ""
        }
    }

    [void]WaitForElement([string]$selector, [int]$timeoutSeconds = 10) {
        $wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait($this.Driver, [TimeSpan]::FromSeconds($timeoutSeconds))
        try {
            $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($selector)))
        }
        catch {
            $this.Logger.Warn("Timeout waiting for element: $selector")
        }
    }

    [void]ExecuteScript([string]$script) {
        try {
            $this.Driver.ExecuteScript($script)
        }
        catch {
            $this.Logger.Error("Script execution failed: $($_.Exception.Message)")
        }
    }

    [void]Close() {
        if ($this.Driver) {
            try {
                $this.Driver.Quit()
                $this.IsInitialized = $false
                $this.Logger.Info("Browser closed")
            }
            catch {
                $this.Logger.Warn("Error closing browser: $($_.Exception.Message)")
            }
        }
    }
}

Export-ModuleMember -Variable *