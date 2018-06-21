# Connect to GovDC vCenter servers

# Create an array of vCenter servers
$hosts = @( 
    "virtvsp-mas006.nswhealth.net", 
    "virtvsp-mas007.nswhealth.net"
);


# Connect 
Connect-VIServer -Server $hosts


# Show list of available vCenter servers and select which one to connect to
Connect-VIServer -Menu


# Get list of connected vCenter servers
$global:DefaultVIServers

#Connect to all vCenters in linked mode
Connect-VIServer "virtvsp-mas006.nswhealth.net" -AllLinked:$true

