$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module AppDynamics | Remove-Module
Import-Module "$AppDModuleLocation\AppDynamics.psd1"

InModuleScope $module {
    Describe "$function Unit Tests" -Tag 'Unit' {
        Context "$function return value validation" {
            # Prepare
            $env:AppDURL = 'mockURL'
            $env:AppDAuth = 'mockAuth'
            $env:AppDAccountID = $null

            Mock Invoke-RestMethod -MockWith {
                $mockData = Import-CliXML -Path "$AppDMockDataLocation\Get-AccountId.Mock"
                return $mockData
            }
            # Act
            $result = Get-AppDAccountId

            # Assert
            It "Returns an id that is not null or empty" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns an id that is a string" {
                $result -is [string] | Should -Be $true
            }
            It "Returns an id that is greater than 0" {
                [int]$result -ge 0 | Should -Be $true
            }
            It "Calls invoke-restmethod and is only invoked once" {
                Assert-MockCalled -CommandName Invoke-RestMethod -Times 1 -Exactly
            }
        }
    }
}