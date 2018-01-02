$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDApplication Unit Tests" -Tag 'Unit' {
        #ToDo : this one is broken right now, need to fix up new mock data for unformatted return.
        <#Context "$AppDFunction return value validation. (`$AppId -eq `$null, `$AppName -eq `$null)" {
            # Prepare
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            Mock New-AppDConnection -MockWith {
                $properties = [ordered]@{
                    accountId = 'mockAccountId'
                    header    = @{'Authorization' = 'mockAuth'}
                }

                return New-Object psobject -Property $properties
            }

            $mockData_ALL = Import-CliXML -Path "$AppDMockDataLocation\$AppDFunction.Mock"
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockData_ALL
            }

            # Act
            $result = Get-AppDApplication

            # Assert
            It "Verifiable mocks are called" {
                Assert-VerifiableMock
            }
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns all aplications" {
                $result.count -eq $mockData_ALL.count | Should -Be $true
            }
            It "Calls Get-AppDResource exactly $(($mockData_ALL.count + 1)) times" {
                Assert-MockCalled -CommandName Get-AppDResource -Times ($mockData_ALL.count + 1) -Exactly
            }
            It "Calls New-AppDConnection exactly 1 time" {
                Assert-MockCalled -CommandName New-AppDConnection -Times 1 -Exactly
            }
        }#>

        Context "$AppDFunction return value validation (`$AppId -eq 1, `$AppName -eq `$null)" {
            # Prepare
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            Mock New-AppDConnection -MockWith {
                $properties = [ordered]@{
                    accountId = 'mockAccountId'
                    header    = @{'Authorization' = 'mockAuth'}
                }

                return New-Object psobject -Property $properties
            }

            $mockData_ID1 = Import-CliXML -Path "$AppDMockDataLocation\$AppDFunction.Mock" | Where-Object {$_.Id -eq 6}
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockData_ID1
            } -ParameterFilter {$uri -eq "controller/api/accounts/mockAccountId/applications/6"}

            # Act
            $result = Get-AppDApplication -AppId 6

            # Assert
            It "Verifiable mocks are called" {
                Assert-VerifiableMock
            }
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns all aplications (count -eq $($mockData_ID1.count))" {
                $result.count -eq $mockData_ID1.count | Should -Be $true
            }
            It "Calls New-AppDConnection exactly 1 time" {
                Assert-MockCalled -CommandName New-AppDConnection -Times 1 -Exactly
            }
            It "Calls Get-AppDResource exactly 1 time" {
                Assert-MockCalled -CommandName Get-AppDResource -Times 1 -Exactly
            }
        }
    }
}