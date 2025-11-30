BeforeAll {
    # Import module under test
    $ModulePath = "$PSScriptRoot/../src/Core/IntentRouter.psm1"
    Import-Module $ModulePath -Force
}

Describe 'IntentRouter' {
    Context 'Intent Classification' {
        It 'Routes browser commands correctly' {
            $result = Get-Intent -UserInput "Navigate to google.com"
            $result.Type | Should -Be 'Browser'
            $result.Confidence | Should -BeGreaterThan 0.8
        }

        It 'Routes PowerShell commands correctly' {
            $result = Get-Intent -UserInput "Get all running processes"
            $result.Type | Should -Be 'PowerShell'
            $result.Confidence | Should -BeGreaterThan 0.7
        }

        It 'Routes chat commands correctly' {
            $result = Get-Intent -UserInput "Explain quantum computing"
            $result.Type | Should -Be 'Chat'
            $result.Confidence | Should -BeGreaterThan 0.6
        }

        It 'Handles ambiguous input with fallback' {
            $result = Get-Intent -UserInput "help"
            $result.Type | Should -BeIn @('Chat', 'Help')
        }
    }

    Context 'Service Selection' {
        It 'Selects ChatGPT for general queries' {
            $result = Select-AIService -Intent 'general-question'
            $result.Service | Should -Be 'ChatGPT'
        }

        It 'Selects Claude for code analysis' {
            $result = Select-AIService -Intent 'code-review'
            $result.Service | Should -Be 'Claude'
        }

        It 'Selects Perplexity for research' {
            $result = Select-AIService -Intent 'research'
            $result.Service | Should -Be 'Perplexity'
        }

        It 'Falls back to default service when unavailable' {
            Mock Test-ServiceAvailability { return $false }
            $result = Select-AIService -Intent 'general' -PreferredService 'Unavailable'
            $result.Service | Should -Be 'ChatGPT'
        }
    }

    Context 'Parameter Extraction' {
        It 'Extracts URL from browser intent' {
            $params = Extract-IntentParameters -Input "Go to github.com/POWDER-RANGER"
            $params.URL | Should -BeLike '*github.com*'
        }

        It 'Extracts command from PowerShell intent' {
            $params = Extract-IntentParameters -Input "Run Get-Process chrome"
            $params.Command | Should -Match 'Get-Process'
        }

        It 'Handles missing parameters gracefully' {
            $params = Extract-IntentParameters -Input "Navigate"
            $params | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error Handling' {
        It 'Throws on null input' {
            { Get-Intent -UserInput $null } | Should -Throw
        }

        It 'Throws on empty input' {
            { Get-Intent -UserInput "" } | Should -Throw
        }

        It 'Handles malformed input gracefully' {
            $result = Get-Intent -UserInput ";;;$$invalid"
            $result.Type | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Confidence Scoring' {
        It 'Returns high confidence for clear intents' {
            $result = Get-Intent -UserInput "Navigate to example.com"
            $result.Confidence | Should -BeGreaterThan 0.9
        }

        It 'Returns lower confidence for vague intents' {
            $result = Get-Intent -UserInput "do something"
            $result.Confidence | Should -BeLessThan 0.6
        }
    }
}

AfterAll {
    Remove-Module IntentRouter -ErrorAction SilentlyContinue
}
