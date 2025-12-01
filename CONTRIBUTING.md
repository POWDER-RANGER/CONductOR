# Contributing to CONductOR

Thank you for considering contributing to CONductOR! This document outlines the process and guidelines.

## Development Setup

1. **Prerequisites**
   - Windows 10/11
   - PowerShell 7+
   - Microsoft Edge
   - Git

2. **Clone and Install**
   ```powershell
   git clone https://github.com/POWDER-RANGER/CONductOR.git
   cd CONductOR
   Install-Module Selenium -Scope CurrentUser
   Install-Module Pester -Scope CurrentUser
   ```

## Making Changes

1. **Fork and Branch**
   ```powershell
   git checkout -b feature/your-feature-name
   ```

2. **Write Tests**
   - Add Pester tests in `tests/` directory
   - Aim for 80%+ code coverage
   - Run tests: `Invoke-Pester -Path ./tests`

3. **Code Style**
   - Follow PowerShell best practices
   - Use approved verbs (Get-, Set-, New-, etc.)
   - Comment complex logic
   - Use meaningful variable names

4. **Commit Messages**
   - Use conventional commits format
   - Examples: `feat: add Claude support`, `fix: browser timeout`, `docs: update README`

## Pull Request Process

1. Update documentation if adding features
2. Ensure all tests pass
3. Update CHANGELOG.md
4. Submit PR with clear description
5. Wait for review and address feedback

## Adding New AI Services

1. Create handler in `handlers/` directory
2. Implement standard interface:
   - `Initialize-Service`
   - `Send-Query`
   - `Get-Response`
3. Add routing logic to intent engine
4. Update README with new service
5. Add integration tests

## Testing

```powershell
# Run all tests
Invoke-Pester -Path ./tests

# Run with coverage
$config = New-PesterConfiguration
$config.CodeCoverage.Enabled = $true
Invoke-Pester -Configuration $config
```

## Questions?

Open an issue or discussion on GitHub.

## License

By contributing, you agree that your contributions will be licensed under the project's license (MIT).