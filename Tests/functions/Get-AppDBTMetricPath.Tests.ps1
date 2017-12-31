$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDBTMetricPath Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation" {
            # Prepare
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            $mockAppData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDApplication.Mock"
            Mock Get-AppDApplication -Verifiable -MockWith {
                return $mockAppData
            }

            $mockBTData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDBTs.Mock"
            Mock Get-AppDBTs -Verifiable -MockWith {
                return $mockBTData
            }

            # Act
            $result = Get-AppDBTMetricPath

            # Assert
            $expectedResult = @()
            foreach ($bt in $mockBTData) {
                $expectedResult += [System.Net.WebUtility]::UrlEncode("$($bt.applicationComponentName)|$($bt.internalName)")
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