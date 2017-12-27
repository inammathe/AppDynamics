@{
    # If authoring a script module, the RootModule is the name of your .psm1 file
    RootModule = 'AppDynamics.psm1'

    Author = 'Evan Lock <inammathe@gmail.com>'

    CompanyName = 'Contoso'

    ModuleVersion = '1.0'

    # Use the New-Guid command to generate a GUID, and copy/paste into the next line
    GUID = 'dae1f11c-68c4-4a54-ae40-3544b6157180'

    Copyright = ''

    Description = 'This is a collection of useful functions to manage AppDynamics'

    # Minimum PowerShell version supported by this module (optional, recommended)
    PowerShellVersion = '5.0'

    # Which PowerShell aliases are exported from your module? (eg. gco)
    #AliasesToExport = @('')

    # Which PowerShell variables are exported from your module? (eg. Fruits, Vegetables)
    #VariablesToExport = @('')
    # Functions to export from this module
    FunctionsToExport = '*'

    # PowerShell Gallery: Define your module's metadata
    PrivateData = @{
        PSData = @{
            # What keywords represent your PowerShell module? (eg. cloud, tools, framework, vendor)
            Tags = @('AppDynamics', 'vendor')

            # What software license is your code being released under? (see https://opensource.org/licenses)
            LicenseUri = ''

            # What is the URL to your project's website?
            ProjectUri = 'https://github.com/inammathe/AppDynamics'

            # What is the URI to a custom icon file for your project? (optional)
            IconUri = ''

            # What new features, bug fixes, or deprecated features, are part of this release?
            ReleaseNotes = @'
'@
        }
    }
    #>
    # If your module supports updateable help, what is the URI to the help archive? (optional)
    # HelpInfoURI = ''
}