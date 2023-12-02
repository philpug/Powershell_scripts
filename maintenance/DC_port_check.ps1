$Servers = "ADSO01", "ADFS02"
$Ports = "135", "389", "636", "3268", "3269", "53", "88", "445"

# Retrieve all writable Domain Controllers
$Destinations = Get-ADDomainController -Filter {IsReadOnly -eq $false} | Select-Object -ExpandProperty HostName

$Results = @()

$ScriptBlock = {
    param($Destinations, $Ports)
    foreach ($Destination in $Destinations) {
        $Object = New-Object PSCustomObject
        $Object | Add-Member -MemberType NoteProperty -Name "ServerName" -Value $env:COMPUTERNAME
        $Object | Add-Member -MemberType NoteProperty -Name "Destination" -Value $Destination
        foreach ($P in $Ports) {
            $PortCheck = (Test-NetConnection -Port $P -ComputerName $Destination).TcpTestSucceeded
            If ($PortCheck -notmatch "True|False") { $PortCheck = "ERROR" }
            $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($PortCheck)"
        }
        $Object
    }
}

foreach ($Server in $Servers) {
    $Results += Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock -ArgumentList $Destinations, $Ports
}

$Results | Out-GridView -Title "Testing Ports"

$Results | Format-Table -AutoSize
