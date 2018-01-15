$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDLicenseInfo Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation" {
            # Prepare
            Mock Write-AppDLog -Verifiable -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            Mock New-AppDConnection -Verifiable -MockWith {
                $properties = [ordered]@{
                    accountId = 'mockAccountId'
                    header    = @{'Authorization' = 'mockAuth'}
                }

                return New-Object psobject -Property $properties
            }

            $mockLicenseModuleData = Import-Clixml "$AppDMockDataLocation\Get-AppDLicenseInfo.modules.Mock"
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockLicenseModuleData
            } -ParameterFilter {$uri -eq 'controller/api/accounts/mockAccountId/licensemodules'}

            $mockLicensePropertiesData = Import-Clixml "$AppDMockDataLocation\Get-AppDLicenseInfo.properties.Mock"
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockLicensePropertiesData
            } -ParameterFilter {$uri -eq '/controller/api/accounts/mockAccountId/licensemodules/java/properties'}

            $mockLicenseUsagesData = Import-Clixml "$AppDMockDataLocation\Get-AppDLicenseInfo.usages.Mock"
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockLicenseUsagesData
            } -ParameterFilter {$uri -eq '/controller/api/accounts/mockAccountId/licensemodules/java/usages'}

            # Act
            $result = Get-AppDLicenseInfo

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
            It "Returns the expected result" {
                $result.usages | ForEach-Object {
                    $_.createdOn -is [DateTime] | Should -Be $true
                }

                ($result.properties | Where-Object {$_.Name -eq 'expiry-date'}).value -is [DateTime] | Should -Be $true
            }
            $expectedNumberOfCalls = ($mockLicenseModuleData.modules.links.count + 1)
            It "Calls Get-AppDResource $expectedNumberOfCalls times (number of link results in first result + itself)" {
                Assert-MockCalled -CommandName Get-AppDResource -Times $expectedNumberOfCalls -Exactly
            }
        }
    }
}