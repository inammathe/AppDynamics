$moduleLocation = (Get-Item (Split-Path -parent $MyInvocation.MyCommand.Path)).parent.FullName
$scriptLocation = "$moduleLocation\Scripts"
$functionsTestLocation = "$moduleLocation\Tests\functions"
$module = 'AppDynamics'

Describe "$module Module Tests" {

    Context "Module Setup" {
        It "has the root module $module.psm1" {
            "$moduleLocation\$module.psm1" | Should -Exist
        }

        It "has the manifest file of $module.psm1" {
            "$moduleLocation\$module.psd1" | Should -Exist
            "$moduleLocation\$module.psd1" | Should -FileContentMatch "$module.psm1"
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
            "$scriptLocation" | Should -Exist
        }

        $functions = (Get-ChildItem $scriptLocation).BaseName

        foreach ($function in $functions) {
            Context "Test Function $function" {
                It "$function.ps1 should exist" {
                    "$scriptLocation\$function.ps1" | Should -Exist
                }

                It "$function.ps1 should contain the AppD identifier" {
                    "$scriptLocation\$function.ps1" | Should -BeLike "*-AppD*"
                }

                It "$function.ps1 should have a SYNOPSIS section in the help block" {
                    "$scriptLocation\$function.ps1" | Should -FileContentMatch '.SYNOPSIS'
                }

                It "$function.ps1 should have a DESCRIPTION section in the help block" {
                    "$scriptLocation\$function.ps1" | Should -FileContentMatch '.DESCRIPTION'
                }

                It "$function.ps1 should have a EXAMPLE section in the help block" {
                    "$scriptLocation\$function.ps1" | Should -FileContentMatch '.EXAMPLE'
                }

                It "$function.ps1 should be an advanced function" {
                    "$scriptLocation\$function.ps1" | Should -FileContentMatch 'function'
                    "$scriptLocation\$function.ps1" | Should -FileContentMatch 'cmdletbinding'
                    "$scriptLocation\$function.ps1" | Should -FileContentMatch 'param'
                    "$scriptLocation\$function.ps1" | Should -FileContentMatch 'Begin'
                    "$scriptLocation\$function.ps1" | Should -FileContentMatch 'Process'
                }

                It "$function.ps1 is valid PowerShell code" {
                    $psFile = Get-Content -path "$scriptLocation\$function.ps1" -ErrorAction Stop
                    $errors = $null
                    [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                    $errors.Count | Should Be 0
                }
            }

            Context "$function has tests" {
                It "$function.Tests.ps1 should exist" {
                    "$functionsTestLocation\$function.Tests.ps1" | Should -Exist
                }
            }
        }
    }
}