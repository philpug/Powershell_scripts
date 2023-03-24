# Import the Active Directory module
Import-Module ActiveDirectory

# Define the Remote Desktop Session Host role name
$RDSSessionHostRole = "RDS-RD-Server"

# Get a list of all servers in Active Directory
$Servers = Get-ADComputer -Filter {OperatingSystem -Like "Windows server*"} -Properties Description

# Define the script block to run on the remote servers
$ScriptBlock = {
    param($RDSSessionHostRole)

    $roles = Get-WindowsFeature -Name $RDSSessionHostRole | Where-Object {$_.Installed}

    if ($roles) {
        # Return the server name and description
        [PSCustomObject]@{
            ServerName = $env:COMPUTERNAME
            Description = (Get-WmiObject -Class Win32_OperatingSystem).Description
        }
    }
}

# Run the script block on each remote server using Invoke-Command
$Results = Invoke-Command -ComputerName $Servers.Name -ScriptBlock $ScriptBlock -ArgumentList $RDSSessionHostRole

# Export the results to a CSV file
$Results | Export-Csv -Path "C:\Path\To\Output\File.csv" -NoTypeInformation
