# To load PowerCLI modules into ISE
# run $profile to check ISE profile path

# Load Windows PowerShell cmdlets for managing vSphere - run the below to add it to the profile so it is loaded each time ISE is opened
 Add-PsSnapin VMware.VimAutomation.Core -ea "SilentlyContinue"# Load Windows PowerShell cmdlets for managing vSphere 
. ‘C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

