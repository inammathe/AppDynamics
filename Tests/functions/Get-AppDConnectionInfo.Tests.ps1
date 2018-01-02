$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDConnectionInfo Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation" {
            # Prepare
            $env:AppDURl = 'mockURL'
            $env:AppDAuth = 'mockAuth'
            $env:AppDAccountId = 'mockID'

            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            # Act
            $result = Get-AppDConnectionInfo

            # Assert
            It "Verifiable mocks are called" {
                Assert-VerifiableMock
            }
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns the expected type" {
                $result -is [object] | Should -Be $true
            }
            It "Returns the expected value" {
                $result.AppDURl -eq $env:AppDURl | Should -Be $true
                $result.AppDAuth -eq $env:AppDAuth | Should -Be $true
                $result.AppDAccountId -eq $env:AppDAccountId | Should -Be $true
            }
            It "Calls Write-AppDLog and is only invoked once" {
                Assert-MockCalled -CommandName Write-AppDLog -Times 1 -Exactly
            }
        }
    }
}