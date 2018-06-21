###########################################################
#
# PowerCLI Script to Deploy VMs using input from a csv file
# See SampleCSV_VMDeployment.csv for sample CSV used for input
#
# Updated to set annotations at the same time
###########################################################


Connect-VIServer xxx
 
$vmlist = Import-CSV "C:\Github\Khanh\VMDeployment\SampleCSV_VMDeploymentTest.csv"
 
foreach ($item in $vmlist) {
 
    $template = $item.template
    $datastore = $item.datastore
    $vmhost = $item.vmhost
    $custspec = $item.custspec
    $vmname = $item.vmname
    $dnsname = $item.dnsname
    $NumCpu = $item.NumCpu
    $MemoryMB = $item.MemoryMB
    $ipaddr = $item.ipaddress
    $pdns = $item.pdns
    $sdns = $item.sdns
    $subnet = $item.subnet
    $gateway = $item.gateway
    $vlan = $item.vlan
    $Annot_AppName = $item.AppName
    $Annot_RFCNumber = $item.RFCNumber
    $Annot_ProvisionedBy = $item.ProvisionedBy

    #Get the Specification and set the Nic Mapping and computername
    Get-OSCustomizationSpec $custspec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns
    
    Get-OSCustomizationSpec $custspec | Set-OSCustomizationSpec -NamingScheme Fixed -NamingPrefix $dnsname
     
    #Clone the template with the adjusted Customization Specification
    New-VM -Name $vmname -Template $template -Datastore $datastore -VMHost $vmhost | Set-VM -OSCustomizationSpec $custspec -Confirm:$false
 
    #Set the Network Name and cpu/ram specs
    Get-VM -Name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $vlan -StartConnected:$true -Confirm:$false
    
    Get-VM -Name $vmname | Set-VM -NumCpu $NumCpu -MemoryMB $MemoryMB -Confirm:$false

    # Set VM annotations
    Get-VM -Name $vmname | Set-Annotation -CustomAttribute "Name" -Value $Annot_AppName -Confirm:$false
    Get-VM -Name $vmname | Set-Annotation -CustomAttribute "RFC Number" -Value $Annot_RFCNumber -Confirm:$false
    Get-VM -Name $vmname | Set-Annotation -CustomAttribute "Provisioned By" -Value $Annot_ProvisionedBy -Confirm:$false
}
