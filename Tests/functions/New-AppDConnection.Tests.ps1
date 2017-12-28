$Global:module = 'AppDynamics'
$Global:function = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:moduleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:mockDataLocation = "$moduleLocation\Tests\mock_data"

Get-Module $module | Remove-Module
Import-Module "$moduleLocation\$module.psd1"

InModuleScope $module {
    Describe "$function Unit Tests" -Tag 'Unit' {
        Context "$function return value validation" {
            # Prepare
            $env:AppDURL = 'mockURL'
            $env:AppDAuth = 'mockAuth'
            $env:AppDAccountID = 'mockAccountId'
            $expectedProperties = [ordered]@{
                accountId = $env:AppDAccountID
                header    = @{'Authorization' = $env:AppDAuth}
            }
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $function}

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