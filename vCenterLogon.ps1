# Connect to xxx vCenter servers

# Create an array of vCenter servers
$hosts = @( 
    "xxx.net", 
    "xxx.net"
);


# Connect 
Connect-VIServer -Server $hosts


# Show list of available vCenter servers and select which one to connect to
Connect-VIServer -Menu


# Get list of connected vCenter servers
$global:DefaultVIServers

#Connect to all vCenters in linked mode
Connect-VIServer "xxx.net" -AllLinked:$true

