<#
.Synopsis
   This script is to check an Active Directory environment for Java installations.
.DESCRIPTION
   Checks for active Windows servers in the domain and created a CSV with 7 columns. Listing the following ServerName, JavaProcessRunning, JavaName, JavaVersion,installDate,JavaInstalled and any Errors.
   Note that in some cases Java will be flagged as running on a server but there is no installation of java. In these cases the server is normally running an OpenJDK or NodeJS service.
.
.NOTES
Author: Phillip Puggioni
Website: https://philpug.com
License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
#>
# Sets the output directory and imports the module needed
Param([string]$csvpath = (Read-Host "Enter the output location of the CSV file eg. C:\temp"))
Import-Module ActiveDirectory
#Creates a data table and adds custom columns to it.
function createDT()
{
    ###Creating a new DataTable###
    $tempTable = New-Object System.Data.DataTable
   
    ##Creating Columns for DataTable##
    $col1 = New-Object System.Data.DataColumn(“ServerName”)
    $col2 = New-Object System.Data.DataColumn(“JavaProcessRunning”)
    $col3 = New-Object System.Data.DataColumn(“JavaName”)
    $col4 = New-Object System.Data.DataColumn(“JavaVersion”)
    $col5 = New-Object System.Data.DataColumn(“installDate”)
    $col6 = New-Object System.Data.DataColumn(“JavaInstalled”)
    $col7 = New-Object System.Data.DataColumn(“Error”)
           
    ###Adding Columns for DataTable###
    $tempTable.columns.Add($col1)
    $tempTable.columns.Add($col2)
    $tempTable.columns.Add($col3)
    $tempTable.columns.Add($col4)
    $tempTable.columns.Add($col5)
    $tempTable.columns.Add($col6)
    $tempTable.columns.Add($col7)   

    return ,$tempTable
}
#Created the list of Servers to run the foreach loop aganist and the data table
$Servers = Get-ADComputer  -Properties * -Filter "(OperatingSystem -Like '*Server*') -and (Enabled -eq '$True') -and (ServicePrincipalName -notLike '*MSServerCluster*')" `
| Select-Object -ExpandProperty Name
$dTable = $null
$dTable = createDT
Write-Host "The script is looking at all active servers in the environment with Java installations. It may take a while to complete please wait...." -NoNewline -ForegroundColor DarkGreen -BackgroundColor White
#Running a loop of the servers list from AD. Checks for the java process running in memory and if the software is installed.
 ForEach ($server in $Servers){
 Try{
$process = $null
$process = Get-Process -ComputerName $server | Where-Object name -Like "*Java*"
If (-not ([string]::IsNullOrEmpty($process))){
$javaprocess = "True"
}
Else 
{$javaprocess = "False"
}
#Kept the architecture part in case it's needed in the future to expand the report to show 32 and 64 bit installations. 
$results = $null
$results = Invoke-Command -ComputerName $Server -ScriptBlock {
$Software = "*java*"
$paths = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
         'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
$props = @(
    @{n='Architecture';
      e={
            if($_.PsParentPath -match 'WOW6432Node'){
                '32-bit'
            }else{
                '64-bit'
            }
        }
    },
    'DisplayName',
    'DisplayVersion',
    'installDate'
)
Get-ItemProperty $paths | Where-Object {$_.displayname -like $Software} | Select-Object $props }
if (-not ([string]::IsNullOrEmpty($results))){
$JavaName = $results | Select-Object -ExpandProperty DisplayName -first 1
$JavaVersion = $results | Select-Object -ExpandProperty DisplayVersion -first 1
$installDate = $results | Select-Object -ExpandProperty installDate -first 1
$JavaInstalled = "True"
}
else{
$JavaName = $null
$JavaVersion = $null
$installDate = $null
$JavaInstalled = "False"
}
# Writes the findings to the datatable creating a new row for every server
$row = $dTable.NewRow()
        $row[“ServerName”] = $Server
        $row[“JavaProcessRunning”] = $javaprocess
        $row[“JavaInstalled”] = $JavaInstalled
        $row[“JavaName"] = $JavaName
        $row[“JavaVersion”] = $JavaVersion
        $row[“installDate”] = $installDate
        $dTable.rows.Add($row)
}
#Writes errors including connection errors to the table so it's clear in the output which servers haven't been contacted.
catch{
        $errormsg = $Error[0].Exception.Message
        $row = $dTable.NewRow()
        $row[“ServerName”] = $Server
        $row[“Error”] = $errormsg
        $dTable.rows.Add($row)
}
}
# Exports the results to the location set by the user
$dTable | Export-Csv $csvpath\java.csv -NoTypeInformation
Write-Host "The Java report has been exports to this location $csvpath" -NoNewline -ForegroundColor DarkGreen -BackgroundColor White
