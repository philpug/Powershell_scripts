<#
This script will generate a RDS report for Microsoft Servers 2016 and 2019 and above.
This script should be ran on the server running the licence service
#>

try{
    Import-Module RemoteDesktopServices -ErrorAction Stop
}
catch{
    Write-Host "Failed to import module"
}

try{
    Set-Location -Path 'rds:' -ErrorAction Stop
    Remove-Item RDS:\LicenseServer\IssuedLicenses\PerUserLicenseReports\* -Recurse
}
catch{
    Write-Host "Could not access the RDS drive" -ForegroundColor Red
}

#Sets the export path and gets the filename of the license report
$path = “C:\scripts\CAL_Reports\RDS-CAL-Report.csv”
$fileName = (Invoke-WmiMethod Win32_TSLicenseReport -Name GenerateReportEx).FileName

#fetches all entries from the report for the attachment
$fileEntries = (Get-WmiObject Win32_TSLicenseReport | Where-Object FileName -eq $fileName).FetchReportEntries(0,0).ReportEntries

#Converts the data into readable formats
$objArray = @()
foreach($entry in $fileEntries){
    $objArray += $entry | select User, ProductVersion, CALType, ExpirationDate
    $objArray[-1].User = $objArray[-1].User.Split('\') | select -Last 1
    $time = $objArray[-1].ExpirationDate.Split('.') | select -first 1
    $objArray[-1].ExpirationDate = [datetime]::ParseExact($time, "yyyyMMddHHmmss", $null)
}

#Creates the CSV from the formatted report entries object array, the path will be used later to reference the file
$objArray | Export-Csv -Path $path -Delimiter ',' -NoTypeInformation
