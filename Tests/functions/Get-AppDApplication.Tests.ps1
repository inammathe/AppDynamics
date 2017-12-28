$Global:module = 'AppDynamics'
$Global:function = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:moduleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:mockDataLocation = "$moduleLocation\Tests\mock_data"

Get-Module $module | Remove-Module
Import-Module "$moduleLocation\$module.psd1"

InModuleScope $module {
    Describe "$function Unit Tests" -Tag 'Unit' {
        Context "$function return value validation. (`$AppId -eq `$null, `$AppName -eq `$null)" {
            # Prepare
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $function}

            Mock New-AppDConnection -MockWith {
                $properties = [ordered]@{
                    accountId = 'mockAccountId'
                    header    = @{'Authorization' = 'mockAuth'}
                }

                return New-Object psobject -Property $properties
            }

            $mockData_ALL = Import-CliXML -Path "$mockDataLocation\$function-ALL.Mock"
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

        Context "$function return value validation (`$AppId -eq 6, `$AppName -eq `$null)" {
            # Prepare
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $function}

            Mock New-AppDConnection -MockWith {
                $properties = [ordered]@{
                    accountId = 'mockAccountId'
                    header    = @{'Authorization' = 'mockAuth'}
                }

                return New-Object psobject -Property $properties
            }

            $mockData_ID6 = Import-CliXML -Path "$mockDataLocation\$function-ID_6.Mock"
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockData_ID6
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
            It "Returns all aplications (count -eq $($mockData_ID6.applications.count))" {
                $result.applications.count -eq $mockData_ID6.applications.count | Should -Be $true
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