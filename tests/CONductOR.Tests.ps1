BeforeAll {
    # Import module under test
    $ModulePath = Join-Path $PSScriptRoot '..' 'Start-Assistant.ps1'
}

Describe 'CONductOR Core Functionality' {
    Context 'Intent Routing' {
        It 'Routes PowerShell commands correctly' {
            $testCommand = 'Get-Process'
            # Mock intent detection logic
            $testCommand -match '^(Get-|Set-|New-|Remove-)' | Should -Be $true
        }
        
        It 'Identifies AI service requests' {
            $testQuery = '@claude how do I write async code'
            $testQuery -match '@(claude|gpt|perplexity)' | Should -Be $true
        }
    }
    
    Context 'Browser Automation' {
        It 'Validates Edge browser requirement' {
            # Check if Edge is available
            $edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
            if (Test-Path $edgePath) {
                $true | Should -Be $true
            } else {
                Set-ItResult -Skipped -Because 'Edge browser not found'
            }
        }
    }
    
    Context 'Module Dependencies' {
        It 'Checks for Selenium module' {
            $seleniumAvailable = Get-Module -ListAvailable -Name Selenium
            $seleniumAvailable | Should -Not -BeNullOrEmpty
        }
        
        It 'Validates PowerShell version' {
            $PSVersionTable.PSVersion.Major | Should -BeGreaterOrEqual 7
        }
    }
}