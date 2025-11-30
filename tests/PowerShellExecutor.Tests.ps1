BeforeAll {
    # Import module under test
    $ModulePath = "$PSScriptRoot/../src/Core/PowerShellExecutor.ps1"
    . $ModulePath
}

Describe 'PowerShellExecutor' {
    Context 'Command Execution' {
        It 'Executes simple Get commands' {
            $result = Invoke-SafeCommand -Command "Get-Process -Name 'powershell'"
            $result.Success | Should -Be $true
            $result.Output | Should -Not -BeNullOrEmpty
        }

        It 'Executes commands with parameters' {
            $result = Invoke-SafeCommand -Command "Get-ChildItem -Path $PSScriptRoot"
            $result.Success | Should -Be $true
            $result.Output | Should -Not -BeNullOrEmpty
        }

        It 'Returns error for invalid commands' {
            $result = Invoke-SafeCommand -Command "Get-InvalidCommand"
            $result.Success | Should -Be $false
            $result.Error | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Safe Mode' {
        It 'Blocks dangerous Remove-Item commands' {
            $result = Invoke-SafeCommand -Command "Remove-Item -Path C:\\ -Recurse" -SafeMode $true
            $result.Success | Should -Be $false
            $result.Error | Should -Match 'blocked|dangerous'
        }

        It 'Blocks Format-Volume commands' {
            $result = Invoke-SafeCommand -Command "Format-Volume -DriveLetter C" -SafeMode $true
            $result.Success | Should -Be $false
            $result.Error | Should -Match 'blocked|dangerous'
        }

        It 'Blocks Invoke-WebRequest piped to Invoke-Expression' {
            $cmd = "Invoke-WebRequest http://example.com/script.ps1 | Invoke-Expression"
            $result = Invoke-SafeCommand -Command $cmd -SafeMode $true
            $result.Success | Should -Be $false
        }

        It 'Blocks Set-ExecutionPolicy Bypass' {
            $result = Invoke-SafeCommand -Command "Set-ExecutionPolicy Bypass" -SafeMode $true
            $result.Success | Should -Be $false
        }

        It 'Allows safe commands in safe mode' {
            $result = Invoke-SafeCommand -Command "Get-Date" -SafeMode $true
            $result.Success | Should -Be $true
        }
    }

    Context 'Command Validation' {
        It 'Validates command syntax before execution' {
            $result = Test-CommandSyntax -Command "Get-Process -Name"
            $result.IsValid | Should -Be $false
        }

        It 'Accepts valid command syntax' {
            $result = Test-CommandSyntax -Command "Get-Process -Name powershell"
            $result.IsValid | Should -Be $true
        }

        It 'Detects script injection attempts' {
            $result = Test-CommandSyntax -Command "Get-Process; Remove-Item C:\\"
            $result.IsValid | Should -Be $false
            $result.Warning | Should -Match 'injection|suspicious'
        }
    }

    Context 'Error Handling' {
        It 'Captures exceptions gracefully' {
            $result = Invoke-SafeCommand -Command "throw 'Test error'"
            $result.Success | Should -Be $false
            $result.Error | Should -Match 'Test error'
        }

        It 'Returns structured error objects' {
            $result = Invoke-SafeCommand -Command "Get-Item -Path 'Z:\\NonExistent'"
            $result.Success | Should -Be $false
            $result.Error | Should -Not -BeNullOrEmpty
            $result.ErrorType | Should -Not -BeNullOrEmpty
        }

        It 'Handles timeout scenarios' {
            Mock Start-Job { return @{ State = 'Running' } }
            Mock Wait-Job { throw 'Timeout' }
            $result = Invoke-SafeCommand -Command "Start-Sleep -Seconds 9999" -Timeout 1
            $result.Success | Should -Be $false
            $result.Error | Should -Match 'timeout'
        }
    }

    Context 'Output Formatting' {
        It 'Returns JSON-serializable output' {
            $result = Invoke-SafeCommand -Command "Get-Date"
            { $result.Output | ConvertTo-Json } | Should -Not -Throw
        }

        It 'Truncates large outputs' {
            $result = Invoke-SafeCommand -Command "Get-Process" -MaxOutputLength 1000
            $result.Output.Length | Should -BeLessOrEqual 1000
        }

        It 'Preserves object types when possible' {
            $result = Invoke-SafeCommand -Command "Get-Process | Select-Object -First 1"
            $result.OutputType | Should -Be 'System.Diagnostics.Process'
        }
    }

    Context 'Logging' {
        It 'Logs all executed commands' {
            $result = Invoke-SafeCommand -Command "Get-Date"
            $logEntry = Get-ExecutionLog -Last 1
            $logEntry.Command | Should -Be "Get-Date"
            $logEntry.Timestamp | Should -Not -BeNullOrEmpty
        }

        It 'Redacts sensitive information in logs' {
            $result = Invoke-SafeCommand -Command "Set-Variable -Name ApiKey -Value 'secret123'"
            $logEntry = Get-ExecutionLog -Last 1
            $logEntry.Command | Should -Not -Match 'secret123'
            $logEntry.Command | Should -Match '\*\*\*\*'
        }
    }

    Context 'Permission Checks' {
        It 'Detects insufficient permissions' {
            Mock Test-Path { return $false }
            $result = Invoke-SafeCommand -Command "Get-Item -Path 'C:\\Windows\\System32\\config\\SAM'"
            $result.Success | Should -Be $false
            $result.Error | Should -Match 'permission|access denied'
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Variable -Name 'ModulePath' -ErrorAction SilentlyContinue
}
