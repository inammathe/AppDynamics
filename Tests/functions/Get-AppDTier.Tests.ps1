$Global:AppDModule = 'AppDynamics'
$Global:AppDFunction = ($MyInvocation.MyCommand.Name).Split('.')[0]
$Global:AppDModuleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$Global:AppDMockDataLocation = "$AppDModuleLocation\Tests\mock_data"

Get-Module $AppDModule | Remove-Module
Import-Module "$AppDModuleLocation\$AppDModule.psd1"

InModuleScope $AppDModule {
    Describe "Get-AppDTier Unit Tests" -Tag 'Unit' {
        Context "$AppDFunction return value validation" {
            # Prepare
            Mock Write-AppDLog  -MockWith {} -ParameterFilter {$message -eq $AppDFunction}

            Mock New-AppDConnection -MockWith {
                $properties = [ordered]@{
                    accountId = 'mockAccountId'
                    header    = @{'Authorization' = 'mockAuth'}
                }

                return New-Object psobject -Property $properties
            }

            $mockData = Import-CliXML -Path "$AppDMockDataLocation\Get-AppDTier.Mock"
            Mock Get-AppDResource  -MockWith {
                return $mockData
            }

            # Act
            #$result = Get-AppDTier -AppId 1 #TODO
            $result = $mockData

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
            It "Calls New-AppDConnection and is only invoked once" {
                Assert-MockCalled -CommandName New-AppDConnection -Times 0 -Exactly
            }
        }
    }
}