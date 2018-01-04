$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDBTCountbyTier Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation (`$AppId -eq `$null, `$AppName -eq `$null)" {
            # Prepare
            Mock Write-AppDLog -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            $mockAppData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDApplication.Mock" | Select-Object -First 1
            Mock Get-AppDApplication -Verifiable -MockWith {
                return $mockAppData
            }

            $mockData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDBTs.Mock"
            Mock Get-AppDBTs -Verifiable -MockWith {
                return $mockData
            }

            # Act
            $result = Get-AppDBTCountbyTier

            # Assert
            $total = 0
            $BTCounts = @()
            foreach ($tier in $mockData.applicationComponentName | sort-object -Unique) {
                $total += ($mockData.applicationComponentName | Where-Object {$_ -eq $tier}).Count
                $BTCounts += [pscustomobject]@{
                    Tier    = $tier
                    BTCount = ($mockData.applicationComponentName | Where-Object {$_ -eq $tier}).Count
                }
            }
            $expectedResult = $BTCounts | Sort-Object BTCount -Descending

            It "Verifiable mocks are called" {
                Assert-VerifiableMock
            }
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns the expected type" {
                $result -is [System.Array] | Should -Be $true
            }
            It "Returns the expected value" {
                for ($i = 0; $i -lt $result.Count; $i++) {
                    ($result[$i].Tier -eq $expectedResult[$i].Tier) | Should -Be $true
                    ($result[$i].BTCount -eq $expectedResult[$i].BTCount) | Should -Be $true
                }
            }
            It "Calls Get-AppDBTs and is only invoked once" {
                Assert-MockCalled -CommandName Get-AppDBTs -Times 1 -Exactly
            }
        }
    }
}