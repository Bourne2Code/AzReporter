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


	else {
		$tPre = '  <td>'
		$tPost = '  </td>'
	}

 ((Get-MsolRole |where-object {$_.Name -eq "Company Administrator"}).ObjectId.Guid).count
 
 (Get-AzureADDirectoryRoleMember -ObjectId (Get-AzureADDirectoryRole |where-object {$_.DisplayName -eq "Global Administrator"}).ObjectId).count
 
 
 $cfgValues = @{ ReportDate = (Get-Date).DateTime; UserCount=0; GroupCount=0; SPCount=0; DomainsTotal=0; DomainsVerified=0; LicenseSkus=0; GlobalAdmins=0; CompanyAdmins=0; AdminUnits=0 }
 
 Set-Content -Path ".\AzReporter.cfg" ($ThisReportData | ConvertTo-Json)
 
 function test-azPreview {
	$cTest = get-command connect-azuread
	if ($cTest.Source -eq 'AzureADPreview') {
		$ret = $true
		write-host 'Preview installed'
	}
	else {
		$ret = $false
		write-host 'Preview NOT installed'
	}
	return $ret
 }
 