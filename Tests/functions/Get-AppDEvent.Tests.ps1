$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDEvent Unit Tests" -Tag 'Unit' {
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

            $mockAppData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDApplication.Mock"
            Mock Get-AppDApplication -MockWith {
                return $mockAppData
            }

            $mockEventData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDEvent.Mock"
            Mock Get-AppDResource -Verifiable -MockWith {
                return $mockEventData
            }

            # Act
            $result = Get-AppDEvent -AppId 1

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
            It "Calls Get-AppDResource and is only invoked once" {
                Assert-MockCalled -CommandName Get-AppDResource -Times 1 -Exactly
            }
        }
    }
}
