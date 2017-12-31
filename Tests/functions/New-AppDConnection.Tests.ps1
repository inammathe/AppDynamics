$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "New-AppDConnection Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation" {
            # Prepare
            $env:AppDURL = 'mockURL'
            $env:AppDAuth = 'mockAuth'
            $env:AppDAccountID = 'mockAccountId'
            $expectedProperties = [ordered]@{
                accountId = $env:AppDAccountID
                header    = @{'Authorization' = $env:AppDAuth}
            }
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            # Act
            $result = New-AppDConnection

            # Assert
            It "Verifiable mocks are called" {
                Assert-VerifiableMock
            }
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns the expected type" {
                $result -is [psobject] | Should -Be $true
            }
            It "Returns the expected value" {
                $result.accountId.name | Should -BeExactly $expectedProperties.accountId.name
                $result.accountId.value | Should -BeExactly $expectedProperties.accountId.value
                $result.header.name | Should -BeExactly $expectedProperties.header.name
                $result.header.value | Should -BeExactly $expectedProperties.header.value
            }
        }
    }
}