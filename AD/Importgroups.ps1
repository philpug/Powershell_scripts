##import
$groups=Import-csv C:\temp\ADGroups.csv

ForEach($group In $groups){
Try {
New-ADGroup -Name $group.samaccountname -GroupScope $group.Groupscope -Path $group.ParentOU -description $group.description 
}
catch {
Write-Host "Group $($Group.samaccountname) was not created!" $Error[0]
}
}
