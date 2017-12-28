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
            $URL = 'http://mockUrl.com'
            $Username = 'mockUsername'
            $Password = 'mockPassword'
            $AccountID = 'mockId'
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $function}
            Mock Get-AppDAccountId -Verifiable -MockWith {
                return $AccountID
            }

            # Act
            $result = Set-AppDConnectionInfo -URL $URL

            # Assert
            #It "Verifiable mocks are called" {
                #Assert-VerifiableMock
            #}
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns the expected value" {
                $result | Should -not -BeNullOrEmpty
            }
            #It "Returns the expected type" {
                #$result -is [string] | Should -Be $true
            #}
            #It "Calls New-AppDConnection and is only invoked once" {
                #Assert-MockCalled -CommandName New-AppDConnection -Times 1 -Exactly
            #}
        }
    }
}