###########################################################
#
# PowerCLI Script to set annotations for VMs
# See SampleAnnotationsVMList.csv for sample CSV used for input
#
###########################################################



Connect-VIServer virtvsp-mas008
 
$vmlist = Import-CSV "D:\Scripts\C481511\annotationsVMList.csv"
 
foreach ($item in $vmlist) {
 
    $vmname = $item.vmname
     
    Set-Annotation -Entity $vmname -CustomAttribute "Application Name" -Value "SWIS " -Confirm:$false
    Set-Annotation -Entity $vmname -CustomAttribute Origin -Value NEWHSS -Confirm:$false
    Set-Annotation -Entity $vmname -CustomAttribute "Production Level" -Value PROD -Confirm:$false
    Set-Annotation -Entity $vmname -CustomAttribute "Provisioned by" -Value "Khanh Pham" -Confirm:$false
    Set-Annotation -Entity $vmname -CustomAttribute "RFC numnber" -Value C:481511 -Confirm:$false
   
    Set-VM $vmname -Description "Project ID 842 - SWIS State-Wide Messaging Expansion and Relocation Project Virtual servers new GovDC  " -Confirm:$false
}