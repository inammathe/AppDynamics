$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDPolicies Unit Tests" -Tag 'Unit' {
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

            $mockAppData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDApplication.Mock" | Select-Object -First 1
            Mock Get-AppDApplication -MockWith {
                return $mockAppData
            }

            $mockData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDPolicies.Mock"
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockData
            } -ParameterFilter {$uri -eq "controller/api/accounts/mockAccountId/applications/6/policies"}

            # Act
            $result = Get-AppDPolicies -AppId 6

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
            It "Returns the expected properties" {
                $expectedProps = @(
                    'id',
                    'name',
                    'type',
                    'enabled',
                    'batchingPerMinute',
                    'triggers',
                    'policyActions')

                foreach ($property in $expectedProps) {
                    $result.PsObject.Properties.Name -contains $property | Should -Be $true
                }
            }
            It "Returns the expected number of objects" {
                @($result).Count -eq @($mockData).Count | Should -Be $true
            }
            It "Calls functions the expected amount of times" {
                Assert-MockCalled -CommandName New-AppDConnection -Times 1 -Exactly
                Assert-MockCalled -CommandName Get-AppDApplication -Times 1 -Exactly
                Assert-MockCalled -CommandName Get-AppDResource -Times 1 -Exactly
            }
        }
    }
}