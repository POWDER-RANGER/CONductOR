# CONductOR

[![CI](https://github.com/POWDER-RANGER/CONductOR/workflows/CI/badge.svg)](https://github.com/POWDER-RANGER/CONductOR/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-blue.svg)](https://docs.microsoft.com/powershell/)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)

**Windows-native AI orchestration assistant. Multi-service chat, browser automation, and PowerShell control.**

## Executive Summary

CONductOR is a Windows-native AI orchestration assistant that provides a unified chat interface to multiple AI services (ChatGPT, Claude, Perplexity) alongside local PowerShell command execution. Unlike API-based tools, CONductOR uses transparent, visible browser automation with your existing service subscriptions, giving you complete visibility and control over AI interactions.

## Core Value Proposition

One chat window to control multiple AI services and your local Windows system, using subscriptions you already pay for, with full transparency into what's happening.

## What CONductOR Does

CONductOR acts as an intelligent bridge between you and multiple AI services. When you type a command or question, it automatically determines whether to execute it locally on your computer or send it to the most appropriate AI service. You see everything happening in real-time through visible browser windows, maintaining complete control and transparency.

## Primary Capabilities

### Multi-Service AI Orchestration
CONductOR connects to ChatGPT, Claude, and Perplexity through visible browser automation. It opens Edge browser windows where you can watch the interaction happen in real-time. This approach uses your existing paid subscriptions rather than requiring separate API access, which saves money and provides features that APIs often don't support (like Claude's artifacts or Perplexity's visual source cards).

### Local PowerShell Execution
Beyond AI queries, CONductOR can execute PowerShell commands directly on your system. When you type commands like `Get-Process` or ask it to list files, it runs these locally and returns results instantly. This creates a seamless experience where you can ask an AI service for help writing a script, then immediately execute that script without switching windows.

### Smart Prompt Refinement
CONductOR includes an optional feature that takes your rough, informal input and refines it into clear, well-structured prompts. If you type "how make async thing work need help", it can transform this into "How do I implement asynchronous operations? I need assistance with making async functionality work." You always see both versions and approve before sending, so you maintain control while benefiting from clearer communication.

### Intelligent Intent Routing
The system analyzes what you're asking and automatically routes your request to the best handler. Research questions go to Perplexity, coding questions go to Claude, general questions go to ChatGPT, and PowerShell commands execute locally. You can also explicitly choose a service using prefixes like `@claude` or `@perplexity`.

### Session Persistence
CONductOR uses your default Edge browser profile, which means it automatically has access to your logged-in sessions for ChatGPT, Claude, and Perplexity. You don't need to manage separate credentials or worry about session expiration - it works just like opening these services in your regular browser.

## Quick Start

### Prerequisites
- Windows 10 (1809+) or Windows 11
- PowerShell 7.x or later
- Microsoft Edge (Chromium-based)
- Active subscriptions to AI services (ChatGPT Plus, Claude Pro, Perplexity Pro recommended)

### Installation

1. **Install PowerShell 7**
   ```powershell
   winget install Microsoft.PowerShell
   ```

2. **Install Selenium Module**
   ```powershell
   Install-Module Selenium -Scope CurrentUser -Force
   ```

3. **Clone and Run**
   ```powershell
   git clone https://github.com/POWDER-RANGER/CONductOR.git
   cd CONductOR
   .\Start-Assistant.ps1
   ```

## Documentation

For complete system documentation, architecture details, troubleshooting, and advanced usage, see [SYSTEM-DOCUMENTATION.md](SYSTEM-DOCUMENTATION.md).

## Key Features

- **Unified Interface**: One chat window for multiple AI services and local commands
- **Transparent Automation**: Visible browser windows show exactly what's happening
- **Cost Effective**: Uses your existing subscriptions, no API fees
- **Smart Routing**: Automatically selects the best service for each query
- **Local Execution**: Run PowerShell commands directly from the chat
- **Session Management**: Leverages your logged-in browser sessions
- **Prompt Enhancement**: Optional refinement for clearer communication

## Architecture

CONductOR is built as a modular PowerShell application with:
- WPF-based chat interface
- Intelligent intent routing engine
- Browser automation controller
- Service-specific handlers for ChatGPT, Claude, and Perplexity
- PowerShell execution environment
- Optional prompt refinement system

## Use Cases

- **Development Workflows**: Ask AI for code help, then execute it immediately
- **Research Tasks**: Query Perplexity for research, then process results locally
- **System Administration**: Combine AI assistance with PowerShell system management
- **Multi-Service Queries**: Compare responses from different AI services
- **Rapid Prototyping**: Iterate quickly between AI suggestions and local testing

## Performance

- Memory: ~500-800 MB with one browser open
- CPU: <1% idle, 10-15% during operations
- Response Times: 2-8 seconds for AI queries, <100ms for local commands

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

CONductOR's modular architecture makes it easy to:
- Add new AI service handlers
- Improve intent routing logic
- Enhance prompt refinement
- Fix bugs and improve stability

## Testing

```powershell
# Run test suite
Invoke-Pester -Path ./tests

# Run with coverage
$config = New-PesterConfiguration
$config.CodeCoverage.Enabled = $true
Invoke-Pester -Configuration $config
```

## Legal Considerations

Browser automation may violate Terms of Service for some AI platforms. CONductOR is designed for personal productivity use. For commercial applications, consider using official APIs instead.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

For issues, questions, or feature requests, please use the [GitHub Issues](https://github.com/POWDER-RANGER/CONductOR/issues) tab.

## Author

Built by [Curtis Farrar](https://github.com/POWDER-RANGER) | ORCID: 0009-0008-9273-2458

---

**Note**: This is a power-user tool that requires technical knowledge of PowerShell and Windows system administration. It provides transparency and control at the cost of requiring more setup than API-based alternatives.