$Global:module = 'AppDynamics'
$Global:function = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:moduleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:mockDataLocation = "$moduleLocation\Tests\mock_data"

Get-Module $module | Remove-Module
Import-Module "$moduleLocation\$module.psd1"

InModuleScope $module {
    Describe "$function Unit Tests" -Tag 'Unit' {
        Context "$function return value validation (`$AppId -eq `$null, `$AppName -eq `$null)" {
            # Prepare
            Mock Write-AppDLog -MockWith {} -ParameterFilter {$message -eq $function}

            $mockData = Import-CliXML -Path "$mockDataLocation\Get-AppDBTs.Mock"
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