# Contributing to CONductOR

Thank you for considering contributing to CONductOR! This guide will help you get started.

## Code of Conduct

By participating in this project, you agree to maintain a respectful, inclusive, and professional environment for all contributors.

## How to Contribute

### Reporting Bugs

1. **Search existing issues** to avoid duplicates
2. **Use the bug report template** when creating new issues
3. **Include detailed information**:
   - Steps to reproduce
   - Expected vs. actual behavior
   - PowerShell version and OS details
   - Error messages or logs

### Suggesting Features

1. **Check existing feature requests** to avoid duplicates
2. **Use the feature request template**
3. **Explain the problem** your feature solves
4. **Describe your proposed solution**
5. **Consider implementation complexity**

## Development Workflow

### Setting Up Development Environment

```powershell
# Clone the repository
git clone https://github.com/POWDER-RANGER/CONductOR.git
cd CONductOR

# Install Pester for testing
Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion 5.0

# Install PSScriptAnalyzer for linting
Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck
```

### Making Changes

1. **Create a feature branch**:
   ```powershell
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our coding standards

3. **Write tests** for new functionality

4. **Run tests locally**:
   ```powershell
   Invoke-Pester -Path ./tests
   ```

5. **Run linter**:
   ```powershell
   Invoke-ScriptAnalyzer -Path ./src -Recurse
   ```

6. **Commit your changes** with a descriptive message:
   ```powershell
   git commit -m "feat: Add browser session persistence"
   ```

### Pull Request Process

1. **Update documentation** for any new features
2. **Ensure all tests pass** locally
3. **Update CHANGELOG.md** with your changes
4. **Push your branch** and create a PR
5. **Fill out the PR template** completely
6. **Respond to code review** feedback

## Coding Standards

### PowerShell Style Guide

- **Indentation**: 4 spaces (no tabs)
- **Line length**: Maximum 120 characters
- **Naming conventions**:
  - Functions: `PascalCase` with approved verbs (`Get-`, `Set-`, `Invoke-`)
  - Variables: `$camelCase`
  - Constants: `$UPPER_CASE`
- **Comments**: Use `#` for single-line, `<# #>` for multi-line
- **Error handling**: Always use `try/catch` for external operations

### Module Structure

```
src/
├── Core/           # Core orchestration logic
├── Services/       # AI service handlers
├── UI/             # User interface components
└── Utils/          # Utility functions

tests/              # Pester tests mirroring src/ structure
```

### Testing Requirements

- **Minimum 70% code coverage** for new code
- **All tests must pass** before PR approval
- **Use descriptive test names**: `It 'Should route browser commands to BrowserController'`
- **Mock external dependencies** (AI services, browser automation)
- **Test error conditions** explicitly

### Documentation Requirements

- **Comment-Based Help** for all functions:
  ```powershell
  <#
  .SYNOPSIS
      Brief description of function
  .DESCRIPTION
      Detailed description
  .PARAMETER ParamName
      Parameter description
  .EXAMPLE
      Get-Intent -UserInput "Navigate to example.com"
  #>
  ```

- **Update README.md** for user-facing changes
- **Update ARCHITECTURE.md** for structural changes

## Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Adding or updating tests
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `chore:` Maintenance tasks

**Examples**:
```
feat: Add retry logic to service calls
fix: Resolve browser selector timeout issue
docs: Update installation instructions
test: Add coverage for IntentRouter error handling
```

## Questions?

Feel free to:
- Open a [Discussion](https://github.com/POWDER-RANGER/CONductOR/discussions)
- Comment on relevant issues
- Reach out to maintainers

Thank you for contributing to CONductOR! 🚀
