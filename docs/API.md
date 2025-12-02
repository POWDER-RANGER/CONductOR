# CONductOR API Reference

## Overview

CONductOR provides a modular PowerShell API for AI orchestration, browser automation, and system control.

## Core Modules

### Intent Router

```powershell
Import-Module ./src/Core/IntentRouter.psm1

# Route user input to appropriate handler
$result = Invoke-IntentRouting -UserInput "search for python tutorials"
```

**Parameters:**
- `UserInput` (string): Raw user query
- `Context` (hashtable, optional): Conversation context

**Returns:**
- `Handler` (string): Assigned handler (chatgpt|claude|perplexity|powershell)
- `Confidence` (double): Routing confidence score
- `ProcessedInput` (string): Cleaned input

### Browser Controller

```powershell
Import-Module ./src/Handlers/BrowserController.psm1

# Initialize Edge browser instance
$browser = New-BrowserSession -Service "chatgpt"

# Send query to AI service
$response = Send-BrowserQuery -Browser $browser -Query "Explain async/await"

# Close browser
Close-BrowserSession -Browser $browser
```

**Functions:**

#### `New-BrowserSession`
Creates a new browser automation instance.

**Parameters:**
- `Service` (string): Target service (chatgpt|claude|perplexity)
- `Headless` (bool, default: false): Run in headless mode
- `UserProfile` (string, optional): Browser profile path

**Returns:** Browser object

#### `Send-BrowserQuery`
Sends query to AI service and retrieves response.

**Parameters:**
- `Browser` (object): Browser session
- `Query` (string): User query
- `Timeout` (int, default: 30): Response timeout in seconds

**Returns:** AI response text

### PowerShell Executor

```powershell
Import-Module ./src/Handlers/PowerShellHandler.psm1

# Execute PowerShell command safely
$result = Invoke-SafeCommand -Command "Get-Process | Select-Object -First 5"
```

**Parameters:**
- `Command` (string): PowerShell command to execute
- `AllowDangerous` (bool, default: false): Allow potentially unsafe commands

**Returns:**
- `Success` (bool): Execution status
- `Output` (string): Command output
- `Error` (string): Error message if failed

### Prompt Refiner

```powershell
Import-Module ./src/Core/PromptRefiner.psm1

# Refine user input for clarity
$refined = Invoke-PromptRefinement -RawInput "find python stuff"
# Returns: "Search for Python programming tutorials and resources"
```

**Parameters:**
- `RawInput` (string): Informal user input
- `TargetService` (string, optional): Optimize for specific AI service

**Returns:** Refined prompt string

## Configuration

### Settings File

Edit `config/settings.json`:

```json
{
  "DefaultService": "chatgpt",
  "BrowserSettings": {
    "Headless": false,
    "Timeout": 30,
    "UserProfile": "Default"
  },
  "PromptRefinement": {
    "Enabled": true,
    "MinLength": 10
  },
  "PowerShell": {
    "AllowDangerousCommands": false,
    "WhitelistedCommands": [
      "Get-*",
      "Select-Object",
      "Where-Object"
    ]
  }
}
```

## Events

### Event Subscription

```powershell
# Subscribe to query events
Register-EngineEvent -SourceIdentifier "QueryStarted" -Action {
    Write-Host "Query started: $($Event.MessageData.Query)"
}

Register-EngineEvent -SourceIdentifier "QueryCompleted" -Action {
    Write-Host "Query completed in $($Event.MessageData.Duration)ms"
}
```

### Available Events
- `QueryStarted`: Fired when query begins processing
- `QueryCompleted`: Fired when query completes
- `BrowserOpened`: Browser session started
- `BrowserClosed`: Browser session terminated
- `ErrorOccurred`: Error encountered

## Error Handling

```powershell
try {
    $result = Invoke-IntentRouting -UserInput $query
    if (-not $result.Success) {
        Write-Error $result.ErrorMessage
    }
} catch {
    Write-Error "Failed to route query: $_"
}
```

## Advanced Usage

### Custom Intent Handlers

```powershell
# Register custom handler
Register-IntentHandler -Name "MyCustomHandler" -Pattern "custom:*" -ScriptBlock {
    param($Input)
    # Custom processing logic
    return @{
        Success = $true
        Response = "Custom response"
    }
}
```

### Pipeline Integration

```powershell
# Process multiple queries
@("query1", "query2", "query3") | ForEach-Object {
    Invoke-IntentRouting -UserInput $_
} | Where-Object { $_.Success }
```

## Performance

- **Startup Time**: ~2-3 seconds
- **Query Routing**: <100ms
- **Browser Automation**: 2-8 seconds (network dependent)
- **PowerShell Execution**: <1 second

## Limitations

- Requires active internet connection for AI services
- Browser automation may break with service UI changes
- PowerShell execution limited to local system
- No built-in rate limiting (respect service ToS)

## Examples

See `examples/` directory for complete usage scenarios.

---

**Last Updated**: December 2025  
**Version**: 0.2.0-alpha
