Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-PimUserString {
$formGetUserSearchString = New-Object System.Windows.Forms.Form
$formGetUserSearchString.Text = 'User Search String'
$formGetUserSearchString.Size = New-Object System.Drawing.Size(500,200)
$formGetUserSearchString.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formGetUserSearchString.AcceptButton = $okButton
$formGetUserSearchString.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(350,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$formGetUserSearchString.CancelButton = $cancelButton
$formGetUserSearchString.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(100,20)
$label.Size = New-Object System.Drawing.Size(300,20)
$label.Text = 'Please enter part of the user name in the space below:'
$formGetUserSearchString.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(110,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$formGetUserSearchString.Controls.Add($textBox)

$formGetUserSearchString.Topmost = $true

$formGetUserSearchString.Add_Shown({$textBox.Select()})
$result = $formGetUserSearchString.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $textBox.Text
}
return $x
# ----------------------------------------------------------------------
}

function Get-PimUser {
	 param ([Parameter(Mandatory,
                   ValueFromPipeline)]
        [string]$PimUserName
    )

$formGetUser = New-Object System.Windows.Forms.Form
$formGetUser.Text = 'Select a User'
$formGetUser.Size = New-Object System.Drawing.Size(500,200)
$formGetUser.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$formGetUser.AcceptButton = $okButton
$formGetUser.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(350,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$formGetUser.CancelButton = $cancelButton
$formGetUser.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(480,20)
$label.Text = 'Please select a UPN / object ID combination below:'
$formGetUser.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(460,20)
$listBox.Height = 80

if ($PimUserName -ne "") {
	$PimUserList = get-azureaduser -SearchString $PimUserName
}

Foreach ($_ in $PimUserList){
   [void] $listBox.Items.Add($_.UserPrincipalName + "  --  " + $_.ObjectId)
}

$formGetUser.Controls.Add($listBox)
$formGetUser.Topmost = $true

$result = $formGetUser.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItem
}
#return only the objectID portion of the user selected.
return $x.SubString($x.LastIndexOf(' ')+1)
}


$ten = (Get-AzureADTenantDetail).ObjectId

$pul = Get-PimUserString 
write-host $pul.count
$pul

if ($pul -ne "") {
	$y = Get-PimUser($pul)
}


$MinorList = Get-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" -ResourceId $ten | where-object  {$_.subjectId -eq $y}
$PimData = @(
foreach ($Item in $MinorList) { 
	$RoleDef = (Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $ten | where-object  {$_.Id -eq $Item.RoleDefinitionId})
   [pscustomobject]@{RoleName = $RoleDef.DisplayName; MemberType = $Item.MemberType; StartDateTime = $Item.StartDateTime; EndDateTime = $Item.EndDateTime}
}
)
#Write-Host "PIM Report for:" (Get-AzureADUser -ObjectId $y).DisplayName
#(Get-AzureADUser -ObjectId $y).DisplayName + " `n" + ($PimData | ft)

$PimData

$rpt = '<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>PIM Report</title>
</head>
<body>
<h1>PIM Report for: ' + (Get-AzureADUser -ObjectId $y).DisplayName + '</h1>
<pre>
 Role Name                   Member Type       Start Date Time      End Date Time
 -------------------------   ---------------   -------------------- --------------------'
Add-Content -Path .\PIMreport.html -Value $rpt


foreach ($Item in $MinorList) { 
	$RoleDef = (Get-AzureADMSPrivilegedRoleDefinition -ProviderId aadRoles -ResourceId $ten | where-object  {$_.Id -eq $Item.RoleDefinitionId})
	
	$rpt = " " + ($RoleDef.DisplayName).PadRight(25) + "   " + ($Item.MemberType).PadRight(15) + "   " + ($Item.StartDateTime) + "   " + ($Item.EndDateTime)

	Add-Content -Path .\PIMreport.html -Value $rpt
}

$rpt = '</pre>
<h1>Tenant Report for: ' + (Get-AzureADUser -ObjectId $y).DisplayName + '</h1>
<pre>
 Role Name                   Member Type       Start Date Time      End Date Time
 -------------------------   ---------------   -------------------- --------------------'



}




$r = "<!doctype html>`r`n<html>`r`n<head>`r`n<meta charset="utf-8">`r`n<title>PIM Report</title>`n</head>`n<body>`r`n"


# AzureResources
$SubList = Get-AzureADMSPrivilegedRoleAssignment -ProviderId "AzureResources" -ResourceId $ten | where-object  {$_.subjectId -eq $y}

Get-AzureADMSPrivilegedRoleSetting -ProviderId AzureResources -Filter "ResourceId eq 'f04093b5-2ab7-4dd8-bec8-2d06b6ebed0d'"