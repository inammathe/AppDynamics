$moduleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.FullName
$scriptLocation = "$moduleLocation\Scripts"
$module = 'AppDynamics'

Describe "$module Module Tests" {

    Context "Module Setup" {
        It "has the root module $module.psm1" {
            "$moduleLocation\$module.psm1" | Should Exist
        }

        It "has the manifest file of $module.psm1" {
            "$moduleLocation\$module.psd1" | Should Exist
            "$moduleLocation\$module.psd1" | Should Contain "$module.psm1"
        }

        It "$module is valid PowerShell code" {
            $psFile = Get-Content -path "$moduleLocation\$module.psm1" -ErrorAction Stop
            $errors = $null
            [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }

    Context "Function Tests" {
        It "has the scripts directory $scriptLocation" {
            "$scriptLocation" | Should Exist
        }

        $functions = (
            'Get-AppDAccountId',
            'Get-AppDApplicationDetail',
            'Get-AppDApplications',
            'Get-AppDAuth',
            'Get-AppDBaseUrl',
            'Get-AppDBTCountbyTier',
            'Get-AppDBTMetricPath',
            'Get-AppDBTMetrics',
            'Get-AppDBTs',
            'Get-AppDConfig',
            'Get-AppDEvent',
            'Get-AppDMetricData',
            'Get-AppDNodeMachines',
            'Get-AppDNodes',
            'Set-AppDAccountId',
            'Set-AppDModuleConfig'
        )

        foreach ($function in $functions) {
            Context "Test Function $function" {
                It "$function.ps1 should exist" {
                    "$scriptLocation\$function.ps1" | Should Exist
                }

                It "$function.ps1 should have a SYNOPSIS section in the help block" {
                    "$scriptLocation\$function.ps1" | Should Contain '.SYNOPSIS'
                }

                It "$function.ps1 should have a DESCRIPTION section in the help block" {
                    "$scriptLocation\$function.ps1" | Should Contain '.DESCRIPTION'
                }

                It "$function.ps1 should have a EXAMPLE section in the help block" {
                    "$scriptLocation\$function.ps1" | Should Contain '.EXAMPLE'
                }

                It "$function.ps1 should be an advanced function" {
                    "$scriptLocation\$function.ps1" | Should Contain 'function'
                    "$scriptLocation\$function.ps1" | Should Contain 'cmdletbinding'
                    "$scriptLocation\$function.ps1" | Should Contain 'param'
                }

                It "$function.ps1 is valid PowerShell code" {
                    $psFile = Get-Content -path "$scriptLocation\$function.ps1" -ErrorAction Stop
                    $errors = $null
                    [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                    $errors.Count | Should Be 0
                }
            }

            <#Context "$function has tests" {
                It "$function.Tests.ps1 should exist" {
                    "$function.Tests.ps1" | Should Exist
                }
            }#>
        }
    }
}