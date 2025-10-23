# SYSTEM-DOCUMENTATION

This document contains the executive summary and setup guide for CONductOR.

## Executive Summary

CONductOR is a Windows-native AI orchestration assistant that provides a unified chat interface to multiple AI services (ChatGPT, Claude, Perplexity) alongside local PowerShell command execution. Unlike API-based tools, CONductOR uses transparent visible browser automation with your existing service subscriptions, giving you complete visibility and control over AI interactions.

Core Value Proposition: One chat window to control multiple AI services and your local Windows system, using subscriptions you already pay for, with full transparency into what's happening.

What CONductOR Does: CONductOR acts as an intelligent bridge between you and multiple AI services. When you type a command or question, it automatically determines whether to execute it locally on your computer or send it to the most appropriate AI service. You see everything happening in real-time through visible browser windows, maintaining complete control and transparency.

Primary Capabilities
- Multi-Service AI Orchestration: Connects to ChatGPT, Claude, and Perplexity through visible browser automation, using your existing paid subscriptions and enabling features that APIs often don't support (Claude artifacts, Perplexity source cards).
- Local PowerShell Execution: Executes PowerShell commands directly on your system (e.g., Get-Process), enabling seamless loops between AI help and immediate execution.
- Smart Prompt Refinement: Optionally refines rough input into clearer prompts with your approval, maintaining control and improving communication.
- Intelligent Intent Routing: Routes requests to the best handler automatically—research to Perplexity, coding to Claude, general to ChatGPT, and executes PowerShell locally. You can force routing via prefixes.
- Session Persistence: Uses your default Edge profile with your logged-in sessions for ChatGPT, Claude, and Perplexity for seamless access.

## Installation and Setup (Quick Guide)

Prerequisites
- Windows 10 (1809+) or Windows 11
- PowerShell 7.x or later
- .NET Framework 4.7.2+ or .NET 6+
- Microsoft Edge (Chromium) and matching EdgeDriver
- PowerShell Selenium module
- Optional: System.Speech for voice features

Step-by-Step Installation
1) Install PowerShell 7
- Microsoft Store: search "PowerShell" and install
- Or via winget: `winget install Microsoft.PowerShell`
- Verify: `pwsh --version` (>= 7.0)

2) Install Selenium Module (in PowerShell 7)
```powershell
Install-Module Selenium -Scope CurrentUser -Force
```

3) Install EdgeDriver
- Check Edge version at edge://version
- Download matching EdgeDriver from Microsoft WebDriver page
- Ensure edgedriver.exe is on PATH or referenced by Selenium

4) Create Directory Structure (example)
```
C:\LocalAssistant\
  Start-Assistant.ps1
  UI\ChatWindow.ps1
  UI\ChatWindow.xaml
  Core\BrowserController.psm1
  Core\IntentRouter.psm1
  Core\PromptRefiner.psm1
  Services\ChatGPTService.psm1
  Services\ClaudeService.psm1
  Services\PerplexityService.psm1
```

5) Verify Service Access
- Log into chat.openai.com, claude.ai, and perplexity.ai in Edge

6) First Launch
```powershell
cd C:\LocalAssistant
./Start-Assistant.ps1
```
- The launcher checks dependencies, installs missing components, and opens the chat window. Update EdgeDriver if versions mismatch.

## Basic Usage
- Natural Language Queries: Routed to the best AI automatically
- PowerShell Commands: Execute locally (e.g., `Get-Process`)
- Explicit Routing: Prefix inputs (e.g., `claude`, `perplexity`, `chatgpt`)
- Prompt Refinement: Optional; shows original and refined versions for approval

For full details, capabilities, architecture, troubleshooting, and legal considerations, see the repository README.
