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

            Mock Get-AppDResource -MockWith {
                $mockData = Import-CliXML -Path "$mockDataLocation\Get-AppDApplication.Mock"
                return $mockData
            } -ParameterFilter {$AppId -eq $null -and $AppName -eq $null}

            Mock Get-AppDResource -MockWith {
                $mockData = Import-CliXML -Path "$mockDataLocation\Get-AppDApplication.Mock"
                return $mockData
            } -ParameterFilter {$AppId -eq '6' -and $AppName -eq $null}

            Mock Get-AppDResource -MockWith {
                $mockData = Import-CliXML -Path "$mockDataLocation\Get-AppDApplication.Mock"
                return $mockData
            } -ParameterFilter {$AppId -eq '9' -and $AppName -eq $null}

            Mock Get-AppDResource -MockWith {
                $mockData = Import-CliXML -Path "$mockDataLocation\Get-AppDApplication.Mock"
                return $mockData
            } -ParameterFilter {$AppId -eq '11' -and $AppName -eq $null}

            $ApplicationData = Get-AppDApplication

            It "$function returns data that is not null or empty" {
                $ApplicationData | Should -not -BeNullOrEmpty
            }
            It "$function returns all aplications" {
                $ApplicationData.count -eq 3 | Should -Be $true
            }
            It "$function calls invoke-restmethod and is only invoked once" {
                Assert-MockCalled -CommandName Get-AppDResource -Times 4 -Exactly
            }
        }
    }
}