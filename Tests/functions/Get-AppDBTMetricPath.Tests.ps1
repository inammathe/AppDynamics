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
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $function}

            $mockAppData = Import-CliXML -Path "$mockDataLocation\Get-AppDApplication.Mock"
            Mock Get-AppDApplication -Verifiable -MockWith {
                return $mockAppData
            }

            $mockBTData = Import-CliXML -Path "$mockDataLocation\Get-AppDBTs.Mock"
            Mock Get-AppDBTs -Verifiable -MockWith {
                return $mockBTData
            }

            # Act
            $result = Get-AppDBTMetricPath

            # Assert
            $expectedResult = @()
            foreach ($bt in $mockBTData) {
                $expectedResult += [System.Web.HttpUtility]::UrlEncode("$($bt.applicationComponentName)|$($bt.internalName)")
            }
            It "Verifiable mocks are called" {
                Assert-VerifiableMock
            }
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns the expected result" {
                for ($i = 0; $i -lt $result.Count; $i++) {
                    $result[$i] -eq $expectedResult[$i] | Should -Be $true
                }
            }
            It "Returns the expected type" {
                $result -is [System.Array] | Should -Be $true
                foreach ($res in $result) {
                    $res -is [String] | Should -Be $true
                }
            }
            It "Calls New-AppDConnection and is only invoked once" {
                Assert-MockCalled -CommandName Get-AppDApplication -Times 1 -Exactly
            }
            It "Calls Get-AppDBTs and is only invoked once" {
                Assert-MockCalled -CommandName Get-AppDBTs -Times 1 -Exactly
            }
        }
    }
}