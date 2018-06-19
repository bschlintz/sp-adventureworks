param(
  [Parameter(Mandatory=$true)]
  $SiteUrl
)

Connect-PnPOnline -Url $SiteUrl

Foreach ($ListCSV in Get-ChildItem -Path "$PSScriptRoot\data\lists\*.csv") {

  $ListTitle = $ListCSV.BaseName
  $List = Get-PnPList $ListTitle -EA 0
  if ($List -eq $null) {
    Write-Host "$(Get-Date): [$ListTitle]: List doesn't exist" -ForegroundColor Yellow
    continue
  }

  Write-Host "$(Get-Date): [$ListTitle]: Removing list" -ForegroundColor Green
  Remove-PnPList $List -Force  
}

Foreach($LibraryFolder in Get-Item "$PSScriptRoot\data\libraries\*") {
  
  $LibraryTitle = $LibraryFolder.Name
  $Library = Get-PnPList $LibraryTitle -EA 0
  if ($Library -eq $null) {
    Write-Host "$(Get-Date): [$LibraryTitle]: Library doesn't exist" -ForegroundColor Yellow
    continue
  }

  Write-Host "$(Get-Date): [$LibraryTitle]: Removing library" -ForegroundColor Green
  Remove-PnPList $Library -Force  
}