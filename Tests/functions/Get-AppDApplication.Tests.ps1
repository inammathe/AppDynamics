$moduleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.parent.FullName
$module = 'AppDynamics'

Get-Module AppDynamics | Remove-Module
Import-Module "$moduleLocation\$module.psd1"

InModuleScope $module {
    $function = 'Get-AppDApplication'
    Describe "$function Unit Tests" -Tag 'Unit' {
        Context "$function return value validation. No Id. No Name." {
            $env:AppDURL = 'mockURL'
            $env:AppDAuth = 'mockAuth'
            $env:AppDAccountID = 'mockAccountID'
            $mockData = Import-CliXML -Path "$mockDataLocation\Get-AppDApplication.Mock"

            Mock Get-AppDResource -MockWith {
                return $mockData
            }

            $ApplicationData = Get-AppDApplication

            It "$function returns data that is not null or empty" {
                $ApplicationData | Should -not -BeNullOrEmpty
            }
            It "$function returns all aplications" {
                $ApplicationData.count -eq $mockData.applications.count | Should -Be $true
            }
            It "$function calls Get-AppDResource invoked exactly $(($mockData.applications.count + 1)) times" {
                Assert-MockCalled -CommandName Get-AppDResource -Times ($mockData.applications.count + 1) -Exactly
            }
        }
    }
}