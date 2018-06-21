$datacenterName= "vDC_UNDHIaaSmgt"

$myhostarray=Get-Datacenter $datacentername |   get-vmhost

$ExpectedPath=8

$reportarray=@()  
$FaultyLunarray=@()


foreach ($myhost in $myhostarray){

    
    $currenthostLuns=$myhost|Get-ScsiLun|where CapacityGB -gt 500 

    $NumGoodLUNs=0
    $NumBadLuns=0

    foreach ($currentLUN in  $currenthostLuns){
    
        $Allpaths = $currentLUN|get-scsilunpath

        $activepaths=$AllPaths|where state -eq "Active"
        $StandbyPaths=$AllPaths|where state -eq "Standby"
        

        $NumAllPath=$AllPaths.count
        $NumActivePath=$activepaths.count
        $NumStndaybyPath=$StandbyPaths.count
        $NumErrorPath=$NumAllPath - $NumActivePath - $NumStndaybyPath

        if($NumErrorPath -gt 0){
        
          $FaultyLunarray+= new-object  –TypeName PSObject   -Property  @{'VMhost'=$myhost.name;'LUN'=$currentLUn.CanonicalName;'NumFautyPath'=$NumErrorPath;'NumAllpath'=$NumAllPath;'NumExpectedPath'=$ExpectedPath}
          $NumBadLUNs+=1

        }else{

             if ($NumAllPath -lt $ExpectedPath){
                $FaultyLunarray+= new-object  –TypeName PSObject   -Property  @{'VMhost'=$myhost.name;'LUN'=$currentLUn.CanonicalName;'NumFautyPath'=$NumErrorPath;'NumAllpath'=$NumAllPath;'NumExpectedPath'=$ExpectedPath}
                $NumBadLUNs+=1
             
              }else{
        
                   
            
                                                                $NumGoodLUNs+=1
            }
        
        }
      
    
    
    }


    $reportarray+= new-object  –TypeName PSObject   -Property  @{'VMhost'=$myhost.name;'NumGoodLuns'=$NumGoodLUNs;'NumBadLuns'=$NumBadLuns;'NumallLuns'=$currenthostLuns.count}
  

  



}

$path1="c:\temp\" + $datacentername + "_faultyLUNreport.csv"

$path2="c:\temp\" + $datacentername + "_AllVMhostLUNPathreport.csv"

$FaultyLunarray|export-csv $path1
$reportarray|export-csv $path2