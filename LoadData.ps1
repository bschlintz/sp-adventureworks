param(
  [Parameter(Mandatory=$true)]
  $SiteUrl,
  $ItemBatchSize = 100,
  $FileBatchSize = 10,
  [Switch]$ListsOnly,
  [Switch]$LibrariesOnly
)

Connect-PnPOnline -Url $SiteUrl

# LOAD LIST DATA FROM CSV FILES
if (!$LibrariesOnly) {
  Foreach ($ListCSV in Get-ChildItem -Path "$PSScriptRoot\data\lists\*.csv") {
    $ListTitle = $ListCSV.BaseName
    $List = Get-PnPList $ListTitle -EA 0
    if ($List -eq $null) {
      Write-Host "$(Get-Date): [$ListTitle]: List doesn't exist" -ForegroundColor Yellow
      continue
    }

    Write-Host "$(Get-Date): [$ListTitle]: Found list" -ForegroundColor Green
    
    $ListData = ConvertFrom-Csv (Get-Content $ListCSV.FullName)
    if ($ListData.Count -eq 0) {
      Write-Host "$(Get-Date):   No rows found in CSV" -ForegroundColor Yellow
      continue
    }

    Write-Host "$(Get-Date):   Loading $($ListData.Count) items from CSV"

    $ListColumns = Get-Member -InputObject $ListData[0] -MemberType NoteProperty | Select-Object -ExpandProperty Name
    $ItemBatchCounter = 0

    Foreach ($Row in $ListData) {          
      $ItemBatchCounter++
    
      $NewItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
      $NewItem = $List.AddItem($NewItemInfo)

      Foreach($ColumnName in $ListColumns) {
        $ColumnValue = $Row.$ColumnName
        if (![string]::IsNullOrEmpty($ColumnValue)) {
          $NewItem[$ColumnName] = $ColumnValue
        }
      }
      $NewItem.Update()

      if ($ItemBatchCounter % $ItemBatchSize -eq 0) {
        Write-Host "$(Get-Date):   Adding batch of $ItemBatchSize items"
        $List.Context.ExecuteQuery()
      }
      elseif ($ListData.Count -eq $ItemBatchCounter) {
        Write-Host "$(Get-Date):   Adding final batch of $($ItemBatchCounter % $ItemBatchSize) items"
        $List.Context.ExecuteQuery()  
      }
    }
  }
}

#LOAD LIBRARY DATA FROM FOLDER FIELS
if (!$ListsOnly) {
  Foreach ($LibraryFolder in Get-Item "$PSScriptRoot\data\libraries\*") {
    $LibraryTitle = $LibraryFolder.Name
    $Library = Get-PnPList $LibraryTitle -EA 0

    if ($Library -eq $null) {
      Write-Host "$(Get-Date): [$LibraryTitle]: Library doesn't exist" -ForegroundColor Yellow
      continue
    }

    Write-Host "$(Get-Date): [$LibraryTitle]: Found library" -ForegroundColor Green

    $LibraryFiles = Get-ChildItem $LibraryFolder\*.*
    if ($LibraryFiles.Count -eq 0) {
      Write-Host "$(Get-Date):   No files found in folder" -ForegroundColor Yellow
      continue
    }

    Write-Host "$(Get-Date):   Uploading $($LibraryFiles.Count) files from folder"

    $FileBatchCounter = 0

    Foreach ($File in $LibraryFiles) {
      $FileBatchCounter++

      $NewFileInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
      $NewFileInfo.Content = Get-Content $File.FullName -Encoding Byte -ReadCount 0
      $NewFileInfo.Url = "$SiteUrl/$($Library.RootFolder.Name)/$($File.Name)"
      $NewFileInfo.Overwrite = $true

      $NewFile = $Library.RootFolder.Files.Add($NewFileInfo)
      $NewFile.Update()

      if ($FileBatchCounter % $FileBatchSize -eq 0) {
        Write-Host "$(Get-Date):   Adding batch of $FileBatchSize files"
        $Library.Context.ExecuteQuery()
      }
      elseif ($LibraryFiles.Count -eq $FileBatchCounter) {
        Write-Host "$(Get-Date):   Adding final batch of $($FileBatchCounter % $FileBatchSize) files"
        $Library.Context.ExecuteQuery()  
      }
    }
  }
}
