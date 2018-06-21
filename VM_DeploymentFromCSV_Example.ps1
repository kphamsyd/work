###########################################################
#
# PowerCLI Script to Deploy VMs 
# Created by BLiebowitz on 9/18/2017
#
###########################################################
 
# Select which vCenter you want to connect to
    Write-host "Select which vCenter to connect to:"
    Write-Host "."
    Write-Host "1. vCenter1"
    Write-Host "2. vCenter2"
    Write-Host "3. vCenter3"
    Write-Host "4. vCenter4"
 
    $Ivcenter = read-host "Select a vCenter Server. Enter Number."
      
    if ($Ivcenter -match "1") {
    $vcenter = "vCenter1"
    } elseif ($Ivcenter -match "2") {
    $vcenter = "vCenter2"
    } elseif ($Ivcenter -match "3") {
    $vcenter = "vCenter3"
    } else {
    $vcenter = "vCenter4"
    }
      
    write-host "."
    Write-Host "You Picked: $($vcenter)"
    write-host "."
    start-sleep -s 3
 
# connect to selected vCenter
    connect-viserver $vcenter
     
# Select which OS you want to deploy
    write-host "."
    write-host "Select an OS to deploy:"
    write-host "."
    Write-Host "1. Windows Server 2016 Standard"
    write-host "2. Windows Server 2012 R2 Standard"
    write-host "3. Windows Server 2008 R2 Standard"
    $Itemplate = read-host "Select Operatingg System. Enter Number."
 
# This section will select the template to use, as well as helps select the Customization Specification. 
    if ($ITemplate -match "1") {
    $Template = "W2K16_STD_TEMPLATE"
    $Spec = "Win2016"
    } elseif ($ITemplate -match "2") {
    $Template =  'W2K12R2_STD TEMPLATE'
    $Spec - "Win2012"
    } else {
    $Template = 'W2K8R2_STD TEMPLATE'
    $Spec = "Win2008R2 - Std"
    }
     
    write-host "."
    Write-Host "You Picked: $($Template)"
    write-host "."
    start-sleep -s 3
     
# Choose which Cluster to deploy to
    write-host "."
    write-host "Choose a Cluster to deploy VMs into: "
    write-host "(it may take a few seconds to build the list)"
    write-host "."
    $ICLUSTER = get-cluster | Select Name | Sort-object Name
    $i = 1
    $ICLUSTER | %{Write-Host $i":" $_.Name; $i++}
    $HCLUSTER = Read-host "Enter the number for the cluster to deploy to."
    $SCLUSTER = $ICLUSTER[$HCLUSTER -1].Name
     
    write-host "."
    write-host "You have selected $($SCLUSTER)."
    write-host "."
    start-sleep -s 3
     
# Set an Environment variable based on cluster (aka Prod, Staging, etc)    
# This will be used to detect the proper vDS switch to use.
    if ($SCluster -match "prod") {
        $ENV = "Prod" }
        elseif ($SCluster -match "citrix") {
            $ENV = "Citrix" }
                elseif ($SCLuster -match "DMZ") {
                    $ENV = "DMZ" }
                        else {
                            $ENV = "Staging" }
     
# Choose a Datastore to deploy to
    Write-host "."
    write-host "Choose a Datastore Cluster to deploy to:"
    Write-host "."
    $Datastores = Get-DatastoreCluster | Select Name | Sort-Object Name
    $i = 1
    $Datastores | %{Write-Host $i":" $_.Name; $i++}
    $DSIndex = Read-Host "Enter a number ( 1 -" $Datastores.count ")"
    $SDatastore = $Datastores[$DSIndex - 1].Name
    Write-Host "You have selected" $SDatastore   
    Start-Sleep -s 3
     
# Choose which Virtual Switch The Required Network will belong to
    $SSwitch = (Get-vdSwitch | Where {$_.Name -match $ENV})
 
# Folder Selection
    Write-Host "Select which folder to store the VM..."
    $IFOLDER = Get-Folder | Select Name | Sort-Object Name
    $i = 1
    $IFOLDER | %{Write-Host $i":" $_.Name; $i++}
    $FSIndex = Read-Host "Select a Folder. Enter a number ( 1 -" $IFOLDER.Count ")"
    $SFOLDER = $IFOLDER[$FSIndex - 1].Name
    write-host "."
    write-host "You Picked folder: \"$SFOLDER
    write-host "."   
    Start-Sleep -s 3
     
# Read Name, Network, vLAN ID from CSV
    foreach ($Row in (import-csv e:\ben\vmware\New_VMs.csv)) {
 
# Set some variables
    $ip = $Row.IP
    $Name = $Row.Name
    $vlan = $Row.vlan    
     
# Deploy new VM &amp;amp;lt;/pre&amp;amp;gt;&amp;amp;lt;pre&amp;amp;gt;
# You can also change -template to -contentlibraryitem <img draggable="false" class="emoji" alt="🙂" src="https://s.w.org/images/core/emoji/2.4/svg/1f642.svg"> 
        $vmhost = Get-Cluster $SCluster | Get-VMHost | Select -First 1
    New-VM -Name $Name -VMHost $vmhost -Template $Template -Datastore $SDatastore -DiskStorageFormat 'Thin' -Location $SFolder -Confirm:$False
     
# Add the network adapter &amp;amp;amp;amp; Move the VM to the proper network</pre><pre>
    $vdswitch = get-vdswitch | where {$_.Name -match $env}
    $virutalportgroup = $vdswitch | get-vdportgroup | Where {$_.Name -match $row.vlan}
    New-Networkadapter -vm $Name -DistributedSwitch $vdswitch -Portgroup $virtualportgroup -StartConnected -Type Vmxnet3  -Confirm:$False
     
# Choose which customization specification to use
# Keep in mind, if you're spec has a NIC Mapping that uses PROMPTUSER, 
# you won't be able to apply the customization via PowerCLI.
    $SSpec = Get-OSCustomizationSpec | where {$_.Name -match $Spec -and $_.Name -match $vlan}
     
# Customize the Guest VM
    Set-VM $Name -OSCustomizationSpec $SSpec -Confirm:$False
     
# Disconnect from vcenter
    Disconnect-viserver $vcenter -Confirm:$false
    }