Import-Module ActiveDirectory 
$grouplist = Get-ADgroup -Filter * -Properties groupscope,description,DistinguishedName| select samaccountname,groupscope,description,DistinguishedName | Sort-Object -Property Name

foreach ($group in $grouplist){
$name = $group | Select-Object -ExpandProperty samaccountname 
$groupscope = $group | Select-Object -ExpandProperty groupscope
$description = $group | Select-Object -ExpandProperty description
$DistinguishedName = $group | Select-Object @{ Name = "ParentOU"; Expression = {[regex]::Match($_.distinguishedname,",(.*)").Groups[1].Value}}
$DistinguishedName = $DistinguishedName.ParentOU

New-Object -TypeName psobject -Property @{
samaccountname = $name
groupscope = $groupscope
description = $description
ParentOU = $DistinguishedName
} | Select-Object samaccountname,groupscope,description,ParentOU | Export-csv -path C:\temp\ADGroups.csv -NoTypeInformation -Append}
