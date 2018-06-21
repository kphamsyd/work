###########################################################
#
# PowerCLI Script to Deploy VMs using input from a csv file
# See SampleCSV_VMDeployment.csv for sample CSV used for input
#
# Updated to set annotations at the same time
###########################################################


Connect-VIServer virtvsp-mas903
 
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
 
    #Get the Specification and set the Nic Mapping and computername
    Get-OSCustomizationSpec $custspec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns
    
    Get-OSCustomizationSpec $custspec | Set-OSCustomizationSpec -NamingScheme Fixed -NamingPrefix $dnsname
     
    #Clone the template with the adjusted Customization Specification
    New-VM -Name $vmname -Template $template -Datastore $datastore -VMHost $vmhost | Set-VM -OSCustomizationSpec $custspec -Confirm:$false
 
    #Set the Network Name and cpu/ram specs
    Get-VM -Name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $vlan -StartConnected:$true -Confirm:$false
    
    Get-VM -Name $vmname | Set-VM -NumCpu $NumCpu -MemoryMB $MemoryMB -Confirm:$false

    # Set VM annotations
    Get-VM -Name $vmname | Set-
    
}