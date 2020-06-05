import-module activedirectory 
$OUlist = Get-ADOrganizationalUnit -Filter * | select name,DistinguishedName

foreach ($OU in $OUlist){
$name = $OU | Select-Object -ExpandProperty name 
$DistinguishedName = $OU | Select-Object @{ Name = "ParentOU"; Expression = {[regex]::Match($_.distinguishedname,",(.*)").Groups[1].Value}}
$DistinguishedName = $DistinguishedName.ParentOU

New-Object -TypeName psobject -Property @{
name = $name
ParentOU = $DistinguishedName 
} | Select-Object name,ParentOU | Export-csv -path C:\temp\ADOrganizationalUnitsexport.csv -NoTypeInformation -Append}
