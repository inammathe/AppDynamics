$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDBTMetrics Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation" {
            # Prepare
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            Mock New-AppDConnection -MockWith {
                $properties = [ordered]@{
                    accountId = 'mockAccountId'
                    header    = @{'Authorization' = 'mockAuth'}
                }

                return New-Object psobject -Property $properties
            }

            #Get-AppDApplication mock
            $mockAppData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDApplication.Mock"

            Mock Get-AppDApplication -Verifiable -MockWith {
                return $mockAppData
            }

            #Get-AppDBTMetricPath mock
            $mockBTMetricPaths = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDMetricPath.Mock"
            Mock Get-AppDBTMetricPath -Verifiable -MockWith {
                return $mockBTMetricPaths
            }

            #Get-AppDMetricData mock
            $mockBTMetricData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDMetricData.Mock"
            Mock Get-AppDMetricData -Verifiable -MockWith {
                return $mockBTMetricData
            }

            # Act
            $result = Get-AppDBTMetrics -ExportCSV -AppId '1' -LiteralPath "$TestDrive\mockBTMetricData.csv"

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
            IT "Exports a CSV file" {
                "$TestDrive\mockBTMetricData.csv" | Should -Exist
                (Get-Item "$TestDrive\mockBTMetricData.csv").Length -gt 0 | Should -Be $true
            }
            It "Calls Get-AppDMetricData and is only invoked once" {
                Assert-MockCalled -CommandName Get-AppDMetricData -Times 1 -Exactly
            }
        }
    }
}