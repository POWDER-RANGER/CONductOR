# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive Pester test suite with 70%+ code coverage
- GitHub Actions CI/CD pipeline with automated testing, linting, and security scanning
- Issue templates for bug reports and feature requests
- Contributing guidelines (CONTRIBUTING.md)
- Security policy and vulnerability reporting guidelines (SECURITY.md)
- Modular PowerShell architecture:
  - IntentRouter for smart command routing
  - BrowserController for web automation
  - PowerShellExecutor for command execution
  - Service handlers for ChatGPT, Claude, and Perplexity
  - ConfigManager and Logger utilities
- WPF-based chat interface (ChatWindow.ps1)
- Project management board with labels and milestones

### Changed
- Improved error handling across all modules
- Enhanced logging with structured output

### Security
- Implemented safe mode for PowerShell execution
- Added input validation and sanitization
- Environment variable-based API key management

## [0.1.0] - 2025-11-30

### Added
- Initial project structure
- MIT License
- README with project overview
- SYSTEM-DOCUMENTATION.md with technical details

[Unreleased]: https://github.com/POWDER-RANGER/CONductOR/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/POWDER-RANGER/CONductOR/releases/tag/v0.1.0
