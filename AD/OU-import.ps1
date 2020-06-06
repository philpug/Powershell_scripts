import-module activedirectory 

$OUlist = import-csv C:\temp\ADOrganizationalUnitsexport.csv

foreach ($OU in $OUlist) 
{
        Try {
        Write-Host "Processing OU Object " $OU.name
        New-ADOrganizationalUnit -Name $OU.name -Path $OU.ParentOU
        }
        Catch {
        Write-Host "Already exists or error found..:" $_ -ForegroundColor Red
        }
}
