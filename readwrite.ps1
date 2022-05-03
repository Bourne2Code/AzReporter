$uCount = 100
$gCount = 22
$rDate = 


we want PoSh so we can manipulate the object attributes

# put our config values in an array
$raw = @{ UserCount= $uCount; GroupCount= $gCount; ServicePCount= 0; }
#convert the array to Json for file read/write
$azRptCfg = $raw | ConvertTo-Json
#write the config data
Set-Content -Path "C:\Test\AzReporter.cfg" $azRptCfg
#read the config data to get a Json
$newValues = Get-Content -Path "C:\Test\AzReporter.cfg" 
convert the Json back into PoSh object
$newCfg = $newValues | ConvertFrom-Json


#$msLicenses = Get-MsolAccountSku
#$i = 0
#foreach ($_ in $Licenses) {
#	$ThisReportData.LicenseSkus += ($Licenses[$i].ConsumedUnits)
#	$i++
#}


function TestParams { 
	param (
		[Parameter(Position=0)]
        $tData,
		[Parameter(Position=1)]
        [boolean]$isHdr,
		[Parameter(Position=2)]
        [string]$Style
    )
write-host "Params: "	$param
write-host "tData: "	$tData
write-host "isHdr: "	$isHdr
write-host "Style: "	$Style
write-host "Param 1: "	$args[1]
}





DeviceManagementApps.Read.All                True    Read Microsoft Intune apps                    Allows the app to r…
DeviceManagementApps.ReadWrite.All           True    Read and write Microsoft Intune apps          Allows the app to r…
DeviceManagementManagedDevices.Read.All      True    Read devices Microsoft Intune devices         Allows the app to r…
DeviceManagementManagedDevices.ReadWrite.All True    Read and write Microsoft Intune devices       Allows the app to r…
DeviceManagementServiceConfig.Read.All       True    Read Microsoft Intune configuration           Allows the app to r…
DeviceManagementServiceConfig.ReadWrite.All  True    Read and write Microsoft Intune configuration Allows the app to r…
Directory.AccessAsUser.All                   True    Access the directory as you                   Allows the app to h…
Directory.Read.All                           True    Read directory data                           Allows the app to r…
Directory.ReadWrite.All                      True    Read and write directory data                 Allows the app to r…
User.Read.All                                True    Read all users' full profiles                 Allows the app to r…
User.ReadBasic.All                           False   Read all users' basic profiles                Allows the app to r…
User.ReadWrite.All

Connect-MgGraph -TenantID f04093b5-2ab7-4dd8-bec8-2d06b6ebed0d -scope `
DeviceManagementApps.Read.All, `
DeviceManagementApps.ReadWrite.All, `
DeviceManagementManagedDevices.Read.All, `
DeviceManagementManagedDevices.ReadWrite.All, `
DeviceManagementServiceConfig.Read.All, `
DeviceManagementServiceConfig.ReadWrite.All, `
Directory.AccessAsUser.All, `
Directory.Read.All, `
Directory.ReadWrite.All, `
Domain.Read.All, `
Domain.ReadWrite.All, `
User.Read.All, `
User.ReadBasic.All, `
User.ReadWrite.All



$domData = "jeepster.tk"
$domUsers = (Get-MgUser -All | Where-Object {$_.UserPrincipalName -like ("*" + ($domData))}).count

Find-MgGraphCommand -command Get-MgDomain | Select -First 1 -ExpandProperty Permissions



$DomCollection = Get-AzureADTenantDetail| select VerifiedDomains



$DomCollection[0].VerifiedDomains |sort-object -Property "Name"
# Get the list of all domains 
$AllDomains = Get-MgDomain | sort-object -Property "Id"
$VerifiedDomains = Get-MgDomain -All | Where-Object {$_.IsVerified -eq $true} | sort-object -Property "Id"

	Write-TD -tData ($AllDomains[$i].Id) -isHdr $False
	Write-TD -tData ($AllDomains[$i].IsVerified) -isHdr $False
	Write-TD -tData ($AllDomains[$i].IsRoot) -isHdr $False
	Write-TD -tData ($AllDomains[$i].IsInitial) -isHdr $False
	Write-TD -tData ($AllDomains[$i].IsDefault) -isHdr $False
	Write-TD -tData ($AllDomains[$i].AuthenticationType) -isHdr $False
	Write-TD -tData ($AllDomains[$i].SupportedServices) -isHdr $False
	Write-TD -tData ($AllDomains[$i].AvailabilityStatus) -isHdr $False






$r = Get-MgDirectoryRole
$rd = Get-AzureADMSRoleDefinition
$t = Get-MgDirectoryRoleTemplate
$at = Get-AzureADDirectoryRoleTemplate
$mt = Get-MgDirectoryRoleTemplate
 
$r[1]|fl  - user admin
 
 
$rd[4] |fl


Id                      : fe930be7-5e62-47db-91af-98c3a49a38b1
OdataType               :
Description             : Can manage all aspects of users and groups, including resetting passwords for limited admins.
DisplayName             : User Administrator
IsBuiltIn               : True
ResourceScopes          : {/}
IsEnabled               : True
RolePermissions         : {class RolePermission {
                            AllowedResourceActions: System.Collections.Generic.List`1[System.String]
                            Condition:
                          }
                          }
TemplateId              : fe930be7-5e62-47db-91af-98c3a49a38b1
Version                 : 1
InheritsPermissionsFrom : {class DirectoryRoleDefinition {
                            Id: 88d8e3e3-8f55-4a1e-953a-9b9898b8876b
                            OdataType:
                            Description:
                            DisplayName:
                            IsBuiltIn:
                            ResourceScopes:
                            IsEnabled:
                            RolePermissions:
                            TemplateId:
                            Version:
                            InheritsPermissionsFrom:
                          }
                          }

 
 
 ($vals -contains "#microsoft.graph.user")
 
 Get-MgDirectoryRoleMember -DirectoryRoleId 19d5d24f-46a4-4afd-aeb4-55746cce04a9
 