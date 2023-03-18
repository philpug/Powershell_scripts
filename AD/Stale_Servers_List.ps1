# Set the threshold date for stale servers
$thresholdDate = (Get-Date).AddMonths(-6)

# Get all server computer objects in AD
$servers = Get-ADComputer -Filter {OperatingSystem -like "*Server*"} -Properties whenchanged

# Loop through each server and check its last update date
foreach ($server in $servers) {
    $lastUpdate = $server.WhenChanged
    if ($lastUpdate -lt $thresholdDate) {
        Write-Output "$($server.Name) hasn't been updated in AD since $($lastUpdate.ToShortDateString())"
    }
}
