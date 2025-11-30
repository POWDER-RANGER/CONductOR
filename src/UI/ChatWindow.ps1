<#
.SYNOPSIS
    WPF-based chat interface for CONductOR

.DESCRIPTION
    Provides a modern dark-themed chat window for interacting with AI services and PowerShell.
    Features: Multi-line input, message history, service routing display, responsive UI.

.NOTES
    Issue: #1 - WPF Chat Interface Foundation
#>

function Start-ChatWindow {
    [CmdletBinding()]
    param([switch]$Debug)

    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

    [xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="CONductOR - AI Orchestration Assistant"
    Height="700" Width="900"
    Background="#1E1E1E"
    WindowStartupLocation="CenterScreen">
    
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Status Bar -->
        <Border Grid.Row="0" Background="#252526" Padding="10,5" CornerRadius="5" Margin="0,0,0,10">
            <TextBlock x:Name="StatusText" Text="Ready | Routing: Auto" Foreground="#00D000" FontSize="12"/>
        </Border>

        <!-- Chat Messages -->
        <Border Grid.Row="1" Background="#252526" CornerRadius="5" Padding="0">
            <ScrollViewer x:Name="MessageScroller" VerticalScrollBarVisibility="Auto">
                <ItemsControl x:Name="ChatMessages" Padding="10">
                    <ItemsControl.ItemTemplate>
                        <DataTemplate>
                            <Border Margin="0,5" Padding="10" Background="#2D2D30" CornerRadius="5">
                                <StackPanel>
                                    <TextBlock Text="{Binding Role}" Foreground="#569CD6" FontWeight="Bold" FontSize="11"/>
                                    <TextBlock Text="{Binding Content}" Foreground="#D4D4D4" FontSize="14" TextWrapping="Wrap" Margin="0,5,0,0"/>
                                    <TextBlock Text="{Binding Timestamp}" Foreground="#858585" FontSize="10" HorizontalAlignment="Right"/>
                                </StackPanel>
                            </Border>
                        </DataTemplate>
                    </ItemsControl.ItemTemplate>
                </ItemsControl>
            </ScrollViewer>
        </Border>

        <!-- Input Area -->
        <Border Grid.Row="2" Background="#252526" CornerRadius="5" Padding="10" Margin="0,10,0,0">
            <TextBox x:Name="InputBox"
                Background="#1E1E1E"
                Foreground="#D4D4D4"
                BorderBrush="#3E3E42"
                BorderThickness="1"
                FontSize="14"
                AcceptsReturn="True"
                TextWrapping="Wrap"
                VerticalScrollBarVisibility="Auto"
                MinHeight="60"
                MaxHeight="150"
                Padding="5"/>
        </Border>

        <!-- Action Buttons -->
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10,0,0">
            <Button x:Name="ClearBtn" Content="Clear" Width="80" Height="30" Margin="0,0,10,0"
                Background="#3E3E42" Foreground="#D4D4D4" BorderBrush="#555" FontSize="12"/>
            <Button x:Name="SendBtn" Content="Send" Width="100" Height="30"
                Background="#0E639C" Foreground="White" BorderBrush="#007ACC" FontWeight="Bold" FontSize="12"/>
        </StackPanel>
    </Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)

    # Get controls
    $inputBox = $window.FindName('InputBox')
    $sendBtn = $window.FindName('SendBtn')
    $clearBtn = $window.FindName('ClearBtn')
    $chatMessages = $window.FindName('ChatMessages')
    $statusText = $window.FindName('StatusText')
    $messageScroller = $window.FindName('MessageScroller')

    # Message collection
    $script:messages = New-Object System.Collections.ObjectModel.ObservableCollection[object]
    $chatMessages.ItemsSource = $script:messages

    # Add welcome message
    $script:messages.Add([PSCustomObject]@{
        Role = 'SYSTEM'
        Content = "Welcome to CONductOR! Type PowerShell commands, ask AI questions, or use @chatgpt, @claude, @perplexity to route explicitly."
        Timestamp = (Get-Date -Format 'HH:mm:ss')
    })

    # Send button click
    $sendBtn.Add_Click({
        $input = $inputBox.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($input)) { return }

        # Add user message
        $script:messages.Add([PSCustomObject]@{
            Role = 'YOU'
            Content = $input
            Timestamp = (Get-Date -Format 'HH:mm:ss')
        })

        $inputBox.Text = ''
        $messageScroller.ScrollToEnd()

        # Process input asynchronously
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.InvokeAsync({
            try {
                # Route and execute (placeholder for now)
                if ($input -match '^[A-Z][a-z]+-[A-Z]') {
                    # PowerShell command detected
                    $statusText.Text = "Executing PowerShell command..."
                    $result = Invoke-Expression $input 2>&1 | Out-String
                    $script:messages.Add([PSCustomObject]@{
                        Role = 'POWERSHELL'
                        Content = $result
                        Timestamp = (Get-Date -Format 'HH:mm:ss')
                    })
                } else {
                    # AI query
                    $statusText.Text = "Routing to AI service..."
                    $script:messages.Add([PSCustomObject]@{
                        Role = 'ASSISTANT'
                        Content = "[Demo Mode] AI routing not yet implemented. Issue #2-5 required."
                        Timestamp = (Get-Date -Format 'HH:mm:ss')
                    })
                }
                $statusText.Text = "Ready | Routing: Auto"
            } catch {
                $script:messages.Add([PSCustomObject]@{
                    Role = 'ERROR'
                    Content = $_.Exception.Message
                    Timestamp = (Get-Date -Format 'HH:mm:ss')
                })
            }
            $messageScroller.ScrollToEnd()
        }.GetNewClosure(), [System.Windows.Threading.DispatcherPriority]::Background)
    })

    # Clear button
    $clearBtn.Add_Click({
        $script:messages.Clear()
        $script:messages.Add([PSCustomObject]@{
            Role = 'SYSTEM'
            Content = "Chat cleared."
            Timestamp = (Get-Date -Format 'HH:mm:ss')
        })
    })

    # Enter key sends (Shift+Enter for new line)
    $inputBox.Add_KeyDown({
        param($sender, $e)
        if ($e.Key -eq 'Return' -and -not $e.KeyboardDevice.Modifiers.HasFlag([System.Windows.Input.ModifierKeys]::Shift)) {
            $e.Handled = $true
            $sendBtn.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)))
        }
    })

    # Show window
    $window.ShowDialog() | Out-Null
}

Export-ModuleMember -Function Start-ChatWindow
