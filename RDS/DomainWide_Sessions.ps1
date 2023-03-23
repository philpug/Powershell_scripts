# Define the name of the output CSV file
$OutputFile = "C:\RDS_Session_Host_Report.csv"

# Define the name of the Remote Desktop Session Host role
$RDSSessionHostRole = "RDS-RD-Server"

# Get a list of all servers in Active Directory that have the Remote Desktop Session Host role installed
$SessionHosts = Get-ADComputer -Filter {OperatingSystem -like "Windows Server*"} -Properties OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion,Description

# Define an empty array to hold the results
$Results = @()

# Loop through each Remote Desktop Session Host server and retrieve additional information
foreach ($SessionHost in $SessionHosts) {
    # Get the server's hostname
    $HostName = $SessionHost.Name

    # Get the server's operating system information
    $OperatingSystem = $SessionHost.OperatingSystem
    $OperatingSystemVersion = $SessionHost.OperatingSystemVersion
    $OperatingSystemServicePack = $SessionHost.OperatingSystemServicePack

    # Get the number of active RDP sessions on the server
    $ActiveSessions = (Get-Counter "\Terminal Services\Active Sessions" -ComputerName $HostName).CounterSamples[0].CookedValue

    # Get the number of disconnected RDP sessions on the server
    $DisconnectedSessions = (Get-Counter "\Terminal Services\Inactive Sessions" -ComputerName $HostName).CounterSamples[0].CookedValue

    # Create a custom object containing the server information and add it to the results array
    $Results += [PSCustomObject] @{
        "ServerName" = $HostName
        "OperatingSystem" = $OperatingSystem
        "OperatingSystemVersion" = $OperatingSystemVersion
        "OperatingSystemServicePack" = $OperatingSystemServicePack
        "ActiveSessions" = $ActiveSessions
        "DisconnectedSessions" = $DisconnectedSessions
    }
}

# Export the results to a CSV file
$Results | Export-Csv -Path $OutputFile -NoTypeInformation
