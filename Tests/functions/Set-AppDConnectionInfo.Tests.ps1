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
            $Username = 'mockUsername@customer1'
            $Password = 'mockPassword'
            $AccountID = 'mockId'
            $Auth = ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName + ":" + $Password )))

            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq "$function`tURL: $URL"}
            Mock Get-AppDAccountId -Verifiable -MockWith {
                return $AccountID
            }

            # Act
            $result = Set-AppDConnectionInfo -URL $URL -Username $Username -Password $Password

            # Assert
            It "Verifiable mocks are called" {
                Assert-VerifiableMock
            }
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns the expected value" {
                $result.AppDURL -eq $URL | Should -Be $true
                $result.AppDAuth -eq $Auth | Should -Be $true
                $result.AppDAccountId -eq $AccountID | Should -Be $true
            }
            It "Returns the expected type" {
                $result -is [psobject] | Should -Be $true
            }
            It "Calls mocks the correct amount of times" {
                Assert-MockCalled -CommandName Write-AppDLog -Times 1 -Exactly
                Assert-MockCalled -CommandName Get-AppDAccountId -Times 1 -Exactly
            }
        }
    }
}