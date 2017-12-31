$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module -ErrorAction SilentlyContinue
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDApplication Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation. (`$AppId -eq `$null, `$AppName -eq `$null)" {
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
                $result.count -eq $mockData_ALL.applications.count | Should -Be $true
            }
            It "Calls Get-AppDResource exactly $(($mockData_ALL.applications.count + 1)) times" {
                Assert-MockCalled -CommandName Get-AppDResource -Times ($mockData_ALL.applications.count + 1) -Exactly
            }
            It "Calls New-AppDConnection exactly 1 time" {
                Assert-MockCalled -CommandName New-AppDConnection -Times 1 -Exactly
            }
        }

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

            $mockData_ID1 = Import-CliXML -Path "$AppDMockDataLocation\$AppDFunction.Mock" | Where-Object {$_.applications.Id -eq 1}
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockData_ID1
            } -ParameterFilter {$uri -eq "controller/api/accounts/mockAccountId/applications/1"}

            # Act
            $result = Get-AppDApplication -AppId 1

            # Assert
            It "Verifiable mocks are called" {
                Assert-VerifiableMock
            }
            It "Returns a value" {
                $result | Should -not -BeNullOrEmpty
            }
            It "Returns all aplications (count -eq $($mockData_ID1.applications.count))" {
                $result.applications.count -eq $mockData_ID1.applications.count | Should -Be $true
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