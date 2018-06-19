param(
  [Parameter(Mandatory=$true)]
  $SiteUrl,
  [Switch]$SkipLoadData
)

Connect-PnPOnline -Url $SiteUrl

Foreach ($ProvisioningSchemaXML in Get-ChildItem -Path "$PSScriptRoot\schemas\*.xml") {
  Write-Host "$(Get-Date): [$($ProvisioningSchemaXML.BaseName)]: Provisioning" -ForegroundColor Green
  Apply-PnPProvisioningTemplate -Path $ProvisioningSchemaXML.FullName -Handlers Lists
}

if (!$SkipLoadData) {
  Write-Host
  Write-Host "$(Get-Date): Invoking LoadData.ps1" -ForegroundColor Yellow

  & $PSScriptRoot\LoadData.ps1 -SiteUrl $SiteUrl
}