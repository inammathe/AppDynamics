$moduleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$module = 'AppDynamics'

Get-Module AppDynamics | Remove-Module
Import-Module "$moduleLocation\$module.psd1"

InModuleScope $module {
    $function = 'Get-AppDApplication'
    Describe "$function Unit Tests" -Tag 'Unit' {
        Context "$function return value validation" {
            $env:AppDURL = 'mockURL'
            $env:AppDAuth = 'mockAuth'
            $env:AppDAccountID = $null

            <#
            Mock Invoke-RestMethod -MockWith {
                $mockData = @"
"@
                return [System.Management.Automation.PSSerializer]::DeserializeAsList($mockData)
            }

            $AccountId = Get-AppDApplication

            It "$function returns an id that is not null or empty" {
                $AccountId | Should -not -BeNullOrEmpty
            }
            It "$function returns an id that is a string" {
                $AccountId -is [string] | Should -Be $true
            }
            It "$function returns an id that is greater than 0" {
                [int]$AccountId -ge 0 | Should -Be $true
            }
            It "$function calls invoke-restmethod and is only invoked once" {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -Exactly
            }#>
        }
    }
}