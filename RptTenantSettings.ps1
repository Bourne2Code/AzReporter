<#PSScriptInfo
 
.VERSION 0.1
 
.AUTHOR Robert Bourne
 
.COMPANYNAME Bourne2Code
 
.COPYRIGHT 2022
 
.TAGS Azure AzureAD Office365
 
.LICENSEURI
 
.PROJECTURI 
 
.ICONURI
 
.EXTERNALMODULEDEPENDENCIES
 
.REQUIREDSCRIPTS
 
.EXTERNALSCRIPTDEPENDENCIES
 
.RELEASENOTES
#>
<#
 
.DESCRIPTION Azure AD Reporter
Will query, record, and report on a number of Azure data points easily reachable via PoSh.
Query - Directory features, roles, settings, etc 
Record - Product and html document representing the query and changes from previous query (queries?)
Record - Record significant counters in a configuration history file with date(s) of collections

.USAGE

Script accepts one command line parameter to turn on/off the login prompts for a GA Account
To force the login prompt:
PS C:>AzRerporter -SignIn $true

To skip the login prompt:
PS C:>AzRerporter -SignIn $false

#>
param (
	[Parameter(Position=0)]
	[boolean]$SignIn
	)
	
write-host "Loading..."

function Confirm-PreviewModule {
# simple /brute force test to see if AzureADPreview module is installed. 
	$ret = $false
	$ModTest = get-command connect-azuread*
	if ($ModTest.Source -eq 'AzureADPreview') {
		$ret = $true
	}
	return $ret
 }
 
function Confirm-MsolModule {
# simple /brute force test to see if MSOnline module is installed. 
	$ret = $false
	$ModTest = get-command connect-msolservice*
	if ($ModTest.Source -eq 'MSOnline') {
		$ret = $true
	}
	return $ret
 }

function Connect-GlobalAdmin {

	$pModExists = Confirm-PreviewModule
	$mModExists = Confirm-MsolModule

	if ($pModExists -and $mModExists) {
		write-host "Modules loaded..."
		connect-azuread
		Connect-msolservice
	}
	else {
		if (($pModExists = $false) -and ($mModExists = $false)) {
			$eMsg = "Missing PowerShell MSOnline and AzureAD Preview Modules."
		}
		if (($pModExists = $false) -and ($mModExists = $true)) {
			$eMsg = "Missing PowerShell AzureAD Preview Module."
		}
		if (($pModExists = $true) -and ($mModExists = $false)) {
			$eMsg = "Missing PowerShell MSOnline Module."
		}
		Halt-Script -ErMsg $eMsg
	}
}

function Count-UsersInDomain {
	param (
        $domData
    )
  if ($tData -ne "") {
    $domUsers = 0
    $domUsers = (Get-AzureADUser -all $true | Where-Object {$_.UserPrincipalName -like ("*" + ($domData))}).count
  }
  return $domUsers
}

function Write-TD { 
	param (
		[Parameter(Position=0)]
        $tData,
		[Parameter(Position=1)]
        [boolean]$isHdr,
		[Parameter(Position=2)]
        [string]$Style
    )
	
	if ($Style -ne "") {
		
		if ($isHdr) {
			$ElementOpen = '  <th ' + $Style + '>'
			$ElementClose = '  </th>'
		}
		else {
			$ElementOpen = '  <td ' + $Style + '>'
			$ElementClose = '  </td>'
		}
	}
	else {
		if ($isHdr) {
			$ElementOpen = '  <th>'
			$ElementClose = '  </th>'
		}
		else {
			$ElementOpen = '  <td>'
			$ElementClose = '  </td>'
		}
	}
	
	if ($tData -ne "") {
	$td = $ElementOpen + $tData + $ElementClose
	}
	else {
	$td = $ElementOpen + '&nbsp;' + $ElementClose
	}
	Add-Content -Path $RptName -Value $td
}

function Write-TableRow {
	param (
		[Parameter(Position=0)]
        [boolean]$OpenRow
    )
	if ($OpenRow -eq $true) {
		Add-Content -Path $RptName -Value ' <tr>'
	}
	else {
		Add-Content -Path $RptName -Value ' </tr>'
	}
}

function Open-Report {
  param (
    $TenName
  )
$rHeader = '<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Tenant Settings Report</title>
<style>
table, th, td {
	border: 2px solid black;
	border-collapse: collapse;
	margin: 0 auto;
}
th, td { padding: .1em .5em; }
th { text-align: left; }
h2 { text-align: center; }
.ChangeUp { color: red; font-weight: bold; }
.ChangeDn { color: green; font-weight: bold; }
.SubHdr { color: blue; font-weight: bold; }
</style>
</head>
<body>
<h1>Tenant Report for: ' 

  if ($RptTenant -ne "") {
    $RptHeader = $rHeader + $TenName + '</h1>'
  }
  else {
    $RptHeader = $rHeader + '&nbsp;</h1>'
  }

# Create file by redirecting to a file
$RptHeader > $RptName
}

function Close-Report {

$rFooter = "</body>
</html>"

	Add-Content -Path $RptName -Value $rFooter

}

function Rpt-DirectorySettings {
# Get-AzureADDirectorySetting returns a collection of settion collections. 
# we will read each  setting collection into its own variable for processing
# Start by getting the entire collection. 

# Get The other source of tenant wide settings 
# This has a lot of fields that should be at the top of a tenant report
$td = Get-AzureADTenantDetail
#The privacy contact and url are in a collection - extract it. 
$prv = $td.PrivacyProfile

Add-Content -Path $RptName -Value ('<h1>Directory Settings</h1>')

Add-Content -Path $RptName -Value ('<h2>Directory - General Settings</h2>')
# start by writing the table of basic tenant settings
Add-Content -Path $RptName -Value '<table>'
Write-TableRow -OpenRow $true
Write-TD -tData "Display Name" -isHdr $True
Write-TD -tData ($td.DisplayName) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Object Id" -isHdr $True
Write-TD -tData ($td.ObjectId) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Object Type" -isHdr $True
Write-TD -tData ($td.ObjectType) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Technical Notification Mails" -isHdr $True
Write-TD -tData ($td.TechnicalNotificationMails) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Privacy Contact Email" -isHdr $True
Write-TD -tData ($prv.ContactEmail) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Privacy Statement URL" -isHdr $True
Write-TD -tData ($prv.StatementUrl) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "DirSync Enabled" -isHdr $True
Write-TD -tData ($td.DirSyncEnabled) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Last DirSync Time" -isHdr $True
Write-TD -tData ($td.CompanyLastDirSyncTime) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Street" -isHdr $True
Write-TD -tData ($td.Street) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "City" -isHdr $True
Write-TD -tData ($td.City) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "State" -isHdr $True
Write-TD -tData ($td.State) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Country" -isHdr $True
Write-TD -tData ($td.Country) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Country Code" -isHdr $True
Write-TD -tData ($td.CountryLetterCode) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Postal Code" -isHdr $True
Write-TD -tData ($td.PostalCode) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Preferred Language" -isHdr $True
Write-TD -tData ($td.PreferredLanguage) -isHdr $False
Write-TableRow -OpenRow $false
Write-TableRow -OpenRow $true
Write-TD -tData "Telephone Number" -isHdr $True
Write-TD -tData ($td.TelephoneNumber) -isHdr $False
Write-TableRow -OpenRow $false
Add-Content -Path $RptName -Value '</table>'

}

function Rpt-Changes {
	Add-Content -Path $RptName -Value ('<h2>Directory Changes</h2>')
	Add-Content -Path $RptName -Value '<table>'
	Write-TableRow -OpenRow $true
	Write-TD -tData "Data" -isHdr $True
	Write-TD -tData ("Last Report") -isHdr $True
	Write-TD -tData ("This Report") -isHdr $True
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Report Date" -isHdr $True
	Write-TD -tData ($LastReportData.ReportDate) -isHdr $False
	Write-TD -tData ($ThisReportData.ReportDate) -isHdr $False
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Users" -isHdr $True
	Write-TD -tData ($LastReportData.UserCount) -isHdr $False 
	if ($LastReportData.UserCount -gt $ThisReportData.UserCount) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.UserCount -lt $ThisReportData.UserCount) {
		$Sty = 'class="ChangeDn"'
	}
	Write-TD -tData ($ThisReportData.UserCount) -isHdr $False $Sty
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Groups" -isHdr $True
	Write-TD -tData ($LastReportData.GroupCount) -isHdr $False
	if ($LastReportData.GroupCount -gt $ThisReportData.GroupCount) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.GroupCount -lt $ThisReportData.GroupCount) {
		$Sty = 'class="ChangeDn"'
	}
	else {
		$Sty = ''
	}
	Write-TD -tData ($ThisReportData.GroupCount) -isHdr $False $Sty
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Service Principals" -isHdr $True
	Write-TD -tData ($LastReportData.SPCount) -isHdr $False
	if ($LastReportData.SPCount -gt $ThisReportData.SPCount) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.SPCount -lt $ThisReportData.SPCount) {
		$Sty = 'class="ChangeDn"'
	}
	else {
		$Sty = ''
	}
	Write-TD -tData ($ThisReportData.SPCount) -isHdr $False $Sty
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Domains" -isHdr $True
	Write-TD -tData ($LastReportData.DomainsTotal) -isHdr $False
	if ($LastReportData.DomainsTotal -gt $ThisReportData.DomainsTotal) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.DomainsTotal -lt $ThisReportData.DomainsTotal) {
		$Sty = 'class="ChangeDn"'
	}
	else {
		$Sty = ''
	}
	Write-TD -tData ($ThisReportData.DomainsTotal) -isHdr $False
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Verified Domains" -isHdr $True
	Write-TD -tData ($LastReportData.DomainsVerified) -isHdr $False
	if ($LastReportData.DomainsVerified -gt $ThisReportData.DomainsVerified) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.DomainsVerified -lt $ThisReportData.DomainsVerified) {
		$Sty = 'class="ChangeDn"'
	}
	else {
		$Sty = ''
	}
	Write-TD -tData ($ThisReportData.DomainsVerified) -isHdr $False $Sty
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "License Skus" -isHdr $True
	Write-TD -tData ($LastReportData.LicenseSkus) -isHdr $False
	if ($LastReportData.LicenseSkus -gt $ThisReportData.LicenseSkus) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.LicenseSkus -lt $ThisReportData.LicenseSkus) {
		$Sty = 'class="ChangeDn"'
	}
	else {
		$Sty = ''
	}
	Write-TD -tData ($ThisReportData.LicenseSkus) -isHdr $False $Sty
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Global Administrators" -isHdr $True
	Write-TD -tData ($LastReportData.GlobalAdmins) -isHdr $False
	if ($LastReportData.GlobalAdmins -gt $ThisReportData.GlobalAdmins) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.GlobalAdmins -lt $ThisReportData.GlobalAdmins) {
		$Sty = 'class="ChangeDn"'
	}
	else {
		$Sty = ''
	}
	Write-TD -tData ($ThisReportData.GlobalAdmins) -isHdr $False $Sty
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Company Administrators" -isHdr $True
	Write-TD -tData ($LastReportData.CompanyAdmins) -isHdr $False
	if ($LastReportData.CompanyAdmins -gt $ThisReportData.CompanyAdmins) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.CompanyAdmins -lt $ThisReportData.CompanyAdmins) {
		$Sty = 'class="ChangeDn"'
	}
	else {
		$Sty = ''
	}
	Write-TD -tData ($ThisReportData.CompanyAdmins) -isHdr $False $Sty
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Administrative Units" -isHdr $True
	Write-TD -tData ($LastReportData.AdminUnits) -isHdr $False
	if ($LastReportData.AdminUnits -gt $ThisReportData.AdminUnits) {
		$Sty = 'class="ChangeUp"'
	}
	elseif ($LastReportData.AdminUnits -lt $ThisReportData.AdminUnits) {
		$Sty = 'class="ChangeDn"'
	}
	else {
		$Sty = ''
	}
	Write-TD -tData ($ThisReportData.AdminUnits) -isHdr $False $Sty
	Write-TableRow -OpenRow $false
	Add-Content -Path $RptName -Value '</table>'
}

function Rpt-Domains {
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report Domains
#
# -----------------------------------------------------------------------------------------------
#
# Var will hold Capabilities value 
$Cap = "none"

# Write the Domains table header
	Add-Content -Path $RptName -Value ('<h2>Directory - Domains</h2>')
	Add-Content -Path $RptName -Value ('<table>')
	Write-TableRow -OpenRow $true
	Write-TD -tData "Name" -isHdr $True
	Write-TD -tData "Verified" -isHdr $True
	Write-TD -tData "Root" -isHdr $True
	Write-TD -tData "Initial" -isHdr $True
	Write-TD -tData "Default" -isHdr $True
	Write-TD -tData "Authentication" -isHdr $True
	Write-TD -tData "Capabilities" -isHdr $True
	Write-TD -tData "State" -isHdr $True
	Write-TD -tData "Availability Status" -isHdr $True
	Write-TD -tData "User Count" -isHdr $True
	Write-TableRow -OpenRow $false

# Write the Domains table content
$i = 0
foreach ($_ in $AllDomains) {
	Write-TableRow -OpenRow $true
	Write-TD -tData ($AllDomains[$i].Name) -isHdr $False
	Write-TD -tData ($AllDomains[$i].IsVerified) -isHdr $False
	Write-TD -tData ($AllDomains[$i].IsRoot) -isHdr $False
	Write-TD -tData ($AllDomains[$i].IsInitial) -isHdr $False
	Write-TD -tData ($AllDomains[$i].IsDefault) -isHdr $False
	Write-TD -tData ($AllDomains[$i].AuthenticationType) -isHdr $False
	
# look up the domain in the other list and get the Capabilities
$y=0
foreach ($_ in $VerifiedDomains) {
	if ((($VerifiedDomains[$y].Name)) -eq ($AllDomains[$i].Name)) {
	  $Cap = (($VerifiedDomains[$y].Capabilities))
    }
	$y++
}
	Write-TD -tData ($Cap) -isHdr $False
	Write-TD -tData ($AllDomains[$i].State) -isHdr $False
	Write-TD -tData ($AllDomains[$i].AvailabilityStatus) -isHdr $False

# Look for user objects with this domain suffix in their UPN
	$UsrCnt = Count-UsersInDomain(($AllDomains[$i].Name))
	Write-TD -tData ($UsrCnt) -isHdr $False
	Write-TableRow -OpenRow $false
	$i++
}
Add-Content -Path $RptName -Value ('</table>')
# -----------------------------------------------------------------------------------------------
#
# END - report Domains
#
# -----------------------------------------------------------------------------------------------
	
}

function Rpt-SettingCollections {
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report SettingCollections
#
# -----------------------------------------------------------------------------------------------
# Loop through each of the collections of settings in $ds to copy them into their own variable.  
# Trying to access a collection within a collection is too hard! 
# Future loops can process one collection at a time

$ds = Get-AzureADDirectorySetting
# Then create an array of objects - 1 per setting collection in the entire collection.
$DirSettings = [Object[]]::new($ds.count)
#
#  DirSettings[0] is the first collection of settings. 
#  DirSettings[1] is the second collection of settings...


Add-Content -Path $RptName -Value ('<h2>Directory - Setting Collections</h2>')

$i = 0
foreach ($_ in $ds) {
	$DirSettings[$i] = $ds[$i]
	$i++
}

# Start writing the report.  
# Outer loop places DisplayName for the settings in a title
# Innter loop writes the settings values in a table format. 

for ($i = 0; $i -lt $ds.count; $i++) {
	# write the section title and table header
    Add-Content -Path $RptName -Value ('<h2>' + ($DirSettings[$i].DisplayName) + '</h2>')
    Add-Content -Path $RptName -Value '<table>'
    Write-TableRow -OpenRow $true
	Write-TD -tData "Config Item DisplayName" -isHdr $True
	Write-TD -tData "Value" -isHdr $True
    Write-TableRow -OpenRow $false
	
	for ($k = 0; $k -lt $DirSettings[$i].Values.count; $k++) {
		# Write the current key/value pair as a table row
		Write-TableRow -OpenRow $true
		Write-TD -tData ($DirSettings[$i].Values[$k].Name) -isHdr $False
		Write-TD -tData ($DirSettings[$i].Values[$k].Value) -isHdr $False
		Write-TableRow -OpenRow $false
	}
	# End of outer loop - close the table
	Add-Content -Path $RptName -Value "</table>"
}
# -----------------------------------------------------------------------------------------------
#
# END - report SettingCollections
#
# -----------------------------------------------------------------------------------------------

}

function Rpt-DirSync {
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report DirSyncFeatures
#
# -----------------------------------------------------------------------------------------------
$dsc = Get-MsolDirSyncConfiguration
$dsf = Get-MsolDirSyncFeatures
$mco = Get-MsolCompanyInformation

# Write the header
	Add-Content -Path $RptName -Value ('<h1>DirSync / AD Connect</h1>')

# Write the header
	Add-Content -Path $RptName -Value ('<h2>Get-MsolCompanySettings</h2>')
	Add-Content -Path $RptName -Value ('<table>')
	Write-TableRow -OpenRow $true
	Write-TD -tData "MSOL Company Settings" -isHdr $True
	Write-TD -tData "Value" -isHdr $True
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Last DirSync Time" -isHdr $False
	Write-TD -tData ($mco.LastDirSyncTime) -isHdr $False
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Password Sync Enabled" -isHdr $False
	Write-TD -tData ($mco.PasswordSynchronizationEnabled) -isHdr $False
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Last Password Sync Time" -isHdr $False
	Write-TD -tData ($mco.LastPasswordSyncTime) -isHdr $False
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "DirSync Service Account" -isHdr $False
	Write-TD -tData ($mco.DirSyncServiceAccount) -isHdr $False
	Write-TableRow -OpenRow $false
	Write-TableRow -OpenRow $true
	Write-TD -tData "Self Service Password Reset Enabled" -isHdr $False
	Write-TD -tData ($mco.SelfServePasswordResetEnabled) -isHdr $False
	Write-TableRow -OpenRow $false
	Add-Content -Path $RptName -Value "</table>"


# Write the DirSyncFeatures table header

	Add-Content -Path $RptName -Value ('<h2>Get-MsolDirSyncFeatures</h2>')
	Add-Content -Path $RptName -Value ('<table>')
	Write-TableRow -OpenRow $true
	Write-TD -tData "DirSync Feature" -isHdr $True
	Write-TD -tData "Enabled" -isHdr $True
	Write-TableRow -OpenRow $false


# Write the DirSyncFeatures table content
$i = 0
foreach ($_ in $dsf) {
	Write-TableRow -OpenRow $true
	Write-TD -tData ($dsf[$i].DirSyncFeature) -isHdr $False
	Write-TD -tData ($dsf[$i].Enabled) -isHdr $False
	Write-TableRow -OpenRow $false
	$i++
}
Add-Content -Path $RptName -Value ('</table>')
# -----------------------------------------------------------------------------------------------
#
# END - report DirSyncFeatures
#
# -----------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report DirSyncConfiguration
#
# -----------------------------------------------------------------------------------------------

# Write the DirSyncFeatures table header

	Add-Content -Path $RptName -Value ('<h2>Get-MsolDirSyncConfiguration</h2>')
	Add-Content -Path $RptName -Value ('<table>')
	Write-TableRow -OpenRow $true
	Write-TD -tData "Extension Data" -isHdr $True
	Write-TD -tData "Accidental Deletion Threshold" -isHdr $True
	Write-TD -tData "Deletion Prevention Type" -isHdr $True
	Write-TableRow -OpenRow $false

# Write the DirSyncFeatures table content
$i = 0
foreach ($_ in $dsc) {
	Write-TableRow -OpenRow $true
	Write-TD -tData ($dsc[$i].ExtensionData) -isHdr $False
	Write-TD -tData ($dsc[$i].AccidentalDeletionThreshold) -isHdr $False
	Write-TD -tData ($dsc[$i].DeletionPreventionType) -isHdr $False
	Write-TableRow -OpenRow $false
	$i++
}
Add-Content -Path $RptName -Value ('</table>')
# -----------------------------------------------------------------------------------------------
#
# END - report DirSyncConfiguration
#
# -----------------------------------------------------------------------------------------------
	
}

function Rpt-DirectoryRoles {

Add-Content -Path $RptName -Value ('<h1>Directory Roles</h1>')
Add-Content -Path $RptName -Value ('<h2>Azure Directory Roles Assigned</h2>')
Add-Content -Path $RptName -Value ('<table>')

$roles = Get-AzureADDirectoryRole
foreach ($_ in $roles) {
  $roleName = ($_.DisplayName)
  $mbrs = Get-AzureADDirectoryRoleMember -ObjectId $_.ObjectId
  if ($mbrs.count -ne 0) {
    Write-TableRow -OpenRow $true
	Write-TD -tData ($roleName) -isHdr $True 'class="SubHdr"'
	Write-TD -tData "Object Type" -isHdr $True 'class="SubHdr"'
    Write-TableRow -OpenRow $false

    foreach ($_ in $mbrs) {
		Write-TableRow -OpenRow $true
		Write-TD -tData ($_.DisplayName) -isHdr $False
		Write-TD -tData ($_.ObjectType) -isHdr $False
		Write-TableRow -OpenRow $false
	}
  }
}

Write-TableRow -OpenRow $false
Add-Content -Path $RptName -Value " </table>"

Add-Content -Path $RptName -Value ('<h2>MS Office Directory Roles Assigned</h2>')
Add-Content -Path $RptName -Value ('<table>')

$roles = Get-MsolRole
foreach ($_ in $roles) {
$roleName = ($_.Name)
  $mbrs = Get-MsolRoleMember -RoleObjectId $_.ObjectId
  if ($mbrs.count -ne 0) {
    Write-TableRow -OpenRow $true
	Write-TD -tData ($roleName) -isHdr $True 'class="SubHdr"'
	Write-TD -tData "Object Type" -isHdr $True 'class="SubHdr"'
    Write-TableRow -OpenRow $false
    foreach ($_ in $mbrs) {
    Write-TableRow -OpenRow $true
	if ($_.RoleMemberType -eq "User"){
		Write-TD -tData ($_.EmailAddress) -isHdr $False
		Write-TD -tData ($_.RoleMemberType.ToString()) -isHdr $False
	}
	else {
		Write-TD -tData ($_.DisplayName) -isHdr $False
		Write-TD -tData ($_.RoleMemberType.ToString()) -isHdr $False
		}
    Write-TableRow -OpenRow $false
	}
  }
}

Write-TableRow -OpenRow $false
Add-Content -Path $RptName -Value " </table>"

}

function Rpt-AdminUnits {
Add-Content -Path $RptName -Value ('<h1>Administrative Units</h1>')

$i = 0
$aUnits = Get-AzureADMSAdministrativeUnit
foreach ($_ in $aUnits) {
	Add-Content -Path $RptName -Value ('<h2>' + ($_.DisplayName) + '</h2>')
	Add-Content -Path $RptName -Value ('<table>')
	Write-TableRow -OpenRow $true
	$uCnt = 0
	$gCnt = 0
	$GrpList = ""
	$ThisUnit = Get-MsolAdministrativeUnitMember -AdministrativeUnitObjectId $_.Id
	$aMembers = $ThisUnit.count;
		foreach ($_ in $ThisUnit) {
			if (($_.AdministrativeUnitMemberType) -eq "User") {
				$uCnt ++
			}
			if (($_.AdministrativeUnitMemberType) -eq "Group") {
				$gCnt ++
				if ($GrpList -eq "") {
					$GrpList = ($_.DisplayName)
				}
				else {
					$GrpList = ($GrpList + ", " + ($_.DisplayName))
				}
			}
		}

		Write-TD -tData "AU Description"  -isHdr $True
		Write-TD -tData ($_.Description) -isHdr $False
		Write-TableRow -OpenRow $false
		Write-TableRow -OpenRow $true
		Write-TD -tData "Member Management Restricted"  -isHdr $True
		Write-TD -tData ($_.IsMemberManagementRestricted) -isHdr $False
		Write-TableRow -OpenRow $false
		Write-TableRow -OpenRow $true
		Write-TD -tData "Membership Rule"  -isHdr $True
		Write-TD -tData ($_.MembershipRule) -isHdr $False
		Write-TableRow -OpenRow $false
		Write-TableRow -OpenRow $true
		Write-TD -tData "Membership Type"  -isHdr $True
		Write-TD -tData ($_.MembershipType) -isHdr $False
		Write-TableRow -OpenRow $false
		Write-TableRow -OpenRow $true
		Write-TD -tData "User Count:"  -isHdr $True
		Write-TD -tData ($uCnt) -isHdr $False
		Write-TableRow -OpenRow $false
		Write-TableRow -OpenRow $true
		Write-TD -tData "Group Count:"  -isHdr $True
		Write-TD -tData ($gCnt) -isHdr $False
		Write-TableRow -OpenRow $false
		Write-TableRow -OpenRow $true
		Write-TD -tData "Group Names:"  -isHdr $True
		Write-TD -tData ($GrpList) -isHdr $False
		Write-TableRow -OpenRow $false

	$i++
	Add-Content -Path $RptName -Value ('</table>')
}
}

function Rpt-Licenses {

# Write the Licenses table
	Add-Content -Path $RptName -Value ('<h1>Licensing</h1>')
	Add-Content -Path $RptName -Value ('<h2>Available Licenses</h2>')
	Add-Content -Path $RptName -Value ('<table>')
	Write-TableRow -OpenRow $true
	Write-TD -tData "License Name" -isHdr $True
	Write-TD -tData "Active Units" -isHdr $True
	Write-TD -tData "Consumed Units" -isHdr $True
	Write-TD -tData "Warning Units" -isHdr $True
	Write-TD -tData "Suspended Units" -isHdr $True
	Write-TD -tData "Sku Id" -isHdr $True
	Write-TableRow -OpenRow $false

	$i = 0
	foreach ($_ in $azLicenses) {
		Write-TableRow -OpenRow $true
		Write-TD -tData ($azLicenses[$i].SkuPartNumber)
		Write-TD -tData ($azLicenses[$i].PrepaidUnits.Enabled)
		Write-TD -tData ($azLicenses[$i].ConsumedUnits)
		Write-TD -tData ($azLicenses[$i].PrepaidUnits.Warning)
		Write-TD -tData ($azLicenses[$i].PrepaidUnits.Suspended)
		Write-TD -tData ($azLicenses[$i].SkuId)
		Write-TableRow -OpenRow $false
		$i++
	}
	Add-Content -Path $RptName -Value ('</table>')

}

function Rpt-AssignedPlans {
#
# BEGIN - report Assigned Plans
#
# The AssignedPlans collection is nested in the settings, so we pull it out into its own collection
$PlanCollection = Get-AzureADTenantDetail | select AssignedPlans
$Plans = $PlanCollection[0].AssignedPlans |sort-object -Property "Service"

# Write the AssignedPlans table
	Add-Content -Path $RptName -Value ('<h2>Assigned Plans</h2>')
	Add-Content -Path $RptName -Value ('<table>')
	Write-TableRow -OpenRow $true
	Write-TD -tData "Assigned Timestamp" -isHdr $True
	Write-TD -tData "Capability Status" -isHdr $True
	Write-TD -tData "Service" -isHdr $True
	Write-TD -tData "Service Plan Id" -isHdr $True
	Write-TableRow -OpenRow $false

$i = 0
foreach ($_ in $Plans) {
	Write-TableRow -OpenRow $true
	Write-TD -tData ($Plans[$i].AssignedTimestamp) -isHdr $False
	Write-TD -tData ($Plans[$i].CapabilityStatus) -isHdr $False
	Write-TD -tData ($Plans[$i].Service) -isHdr $False
	Write-TD -tData ($Plans[$i].ServicePlanId) -isHdr $False
	Write-TableRow -OpenRow $false
	$i++
}
Add-Content -Path $RptName -Value ('</table>')

# END - report AssignedPlans
#
}

function Read-arConfig {
	#This object holds counts of objects from last sucessful run if found, so define it before we populate it. 
	if (test-path AzReporter.cfg) {
		#read the config data to get a Json
		$cfgValues = (Get-Content -Path ".\AzReporter.cfg" | ConvertFrom-Json)
	}
	else {
		$cfgValues = @{ ReportDate = (Get-Date).DateTime; UserCount=0; GroupCount=0; SPCount=0; DomainsTotal=0; DomainsVerified=0; LicenseSkus=0; GlobalAdmins=0; CompanyAdmins=0; AdminUnits=0 }
	}
	#convert the Json back into PoSh object 
	return ($cfgValues)
}

function Write-arConfig {
	Set-Content -Path ".\AzReporter.cfg" ($ThisReportData | ConvertTo-Json)
}

function Halt-Script {
	param (
		[Parameter(Position=0)]
        $ErMsg
		)
	write-host $ErMsg
}	


function Rpt-Apps {
# -----------------------------------------------------------------------------------------------
#
# BEGIN - report Applications
#
# -----------------------------------------------------------------------------------------------

# Write the Apps table header
	Add-Content -Path $RptName -Value ('<h2>Directory - Applications</h2>')
	Add-Content -Path $RptName -Value ('<table>')
	Write-TableRow -OpenRow $true
	Write-TD -tData "App Name" -isHdr $True
	Write-TD -tData "Owner" -isHdr $True
	Write-TD -tData "Created" -isHdr $True
	Write-TD -tData "Tags" -isHdr $True
	Write-TD -tData "App ID" -isHdr $True
	Write-TableRow -OpenRow $false


	$AzApps = Get-AzureADMSApplication -all $true  |sort-object -Property "DisplayName"

	$i = 0
	for ($i = 0; $i -lt $AzApps.count; $i++) {
		Write-TableRow -OpenRow $true
		Write-TD -tData ($AzApps[$i].DisplayName) -isHdr $false
		Write-TD -tData ((Get-AzureADApplicationOwner -objectID ($AzApps[$i].id)).UserPrincipalName) -isHdr $false
		Write-TD -tData ($AzApps[$i].CreatedDateTime) -isHdr $false
		Write-TD -tData ($AzApps[$i].DeletedDateTime) -isHdr $false
		Write-TD -tData ($AzApps[$i].Tags) -isHdr $false
		Write-TD -tData ($AzApps[$i].AppId) -isHdr $false
		Write-TD -tData ($AzApps[$i].SignInAudience) -isHdr $false
		Write-TableRow -OpenRow $false
	}
	Add-Content -Path $RptName -Value ('</table>')

}



# Begin Script! 
if ($SignIn -eq $true) {
	Connect-GlobalAdmin
}

$LastReportData = Read-arConfig
$ThisReportData = @{ ReportDate = (Get-Date).DateTime; UserCount=0; GroupCount=0; SPCount=0; DomainsTotal=0; DomainsVerified=0; LicenseSkus=0; GlobalAdmins=0; CompanyAdmins=0; AdminUnits=0 }
$TenantName =(Get-AzureADTenantDetail).DisplayName

$RptName = (".\AzReporter - " + $TenantName + ".html")

# -----------------------------------------------------------------------------------------------------
write-host "Checking for changes since" $LastReportData.ReportDate "..."

# Get the collection of VerifiedDomains - it is a collection in a collection - too hard to loop through
$DomCollection = Get-AzureADTenantDetail| select VerifiedDomains
$VerifiedDomains = $DomCollection[0].VerifiedDomains |sort-object -Property "Name"
# Get the list of all domains 
$AllDomains = Get-AzureADDomain | sort-object -Property "Name"
# Update current report counters

# update user count by counting all users in each domain
$i = 0
foreach ($_ in $AllDomains) {
	$UsrCnt = Count-UsersInDomain(($AllDomains[$i].Name))
	$ThisReportData.UserCount += $UsrCnt
	$i++
}
$ThisReportData.DomainsTotal = $AllDomains.count
$ThisReportData.DomainsVerified = $VerifiedDomains.count
$ThisReportData.GroupCount = (get-azureadgroup -all $true).count
$ThisReportData.AdminUnits = (Get-AzureADMSAdministrativeUnit).count
$ThisReportData.LicenseSkus = (Get-AzureADSubscribedSku).count
$ThisReportData.SPcount = (Get-AzureADMSServicePrincipal -all $true).count
$ThisReportData.GlobalAdmins = (Get-AzureADDirectoryRoleMember -ObjectId (Get-AzureADDirectoryRole |where-object {$_.DisplayName -eq "Global Administrator"}).ObjectId).count
$ThisReportData.CompanyAdmins = ((Get-MsolRole |where-object {$_.Name -eq "Company Administrator"}).ObjectId.Guid).count
$azLicenses = Get-AzureADSubscribedSku


write-host "Creating report..."
Open-Report ($TenantName)

write-host "Writing Tenant Settings..."
Rpt-DirectorySettings
write-host "Changes..."
Rpt-Changes
write-host "Writing Domains..."
Rpt-Domains
write-host "Writing Setting Collections..."
Rpt-SettingCollections

if ((Get-AzureADTenantDetail).DirSyncEnabled) {
	write-host "Writing Directory Sync..."
	Rpt-DirSync
}
write-host "Writing Admin Units..."
Rpt-AdminUnits
write-host "Writing Directory Roles..."
Rpt-DirectoryRoles
write-host "Writing Licenses..."
Rpt-Apps
Rpt-Licenses
Rpt-AssignedPlans

write-host "Closing report..."
Close-Report
write-host "Updating tenant report config..."
Write-arConfig
write-host "Done!"
