Import-Module -Name AWS.Tools.SimpleSystemsManagement, SimplySql

Set-DefaultAWSRegion -Region us-west-2

$Filter = [Amazon.SimpleSystemsManagement.Model.DocumentKeyValuesFilter]::new()
$Filter.Key = 'Owner'
$Filter.Values = 'Public'

Open-SqliteConnection -DataSource aws-systemsmanager-publicdocuments.sqlite

$ScriptDate = Get-Date
$TargetFolder = 'documents/{0}' -f (Get-Date -Format 'yyyy/MM/dd')

# Create directory for files, if it doesn't exist.
New-Item -ItemType Directory -Path $TargetFolder -ErrorAction Ignore

$DocList = Get-SSMDocumentList -Filter $Filter

$READMEBuilder = [System.Text.StringBuilder]::new()

foreach ($Document in $DocList) {
  $CurrentDocument = Get-SSMDocument -Name $Document.Name -DocumentVersion $Document.DocumentVersion
  $FileName = '{0}/{1}-{2}-{3}.json' -f $TargetFolder, $Document.Owner, $CurrentDocument.Name.Split('/')[-1], $Document.DocumentVersion
  $CurrentDocument | ConvertTo-Json -Depth 10 | Set-Content -Path $FileName
  
  $ReadmeLine = '|{0}|{1}|{2}|{3}|{4}|{5}|{6}|' -f $Document.Owner, $Document.Name, $CurrentDocument.DocumentType.Value, $CurrentDocument.DocumentFormat.Value, $Document.DocumentVersion, $CurrentDocument.CreatedDate.ToString('u'), ($CurrentDocument.AttachmentsContent ? $CurrentDocument.AttachmentsContent.Count : 0)
  $null = $READMEBuilder.AppendLine($ReadmeLine)
}

# Update the README.md with the latest information
(Get-Content -Path README.template.md -Raw) -replace '\{\{DOCUMENT_LIST\}\}' | Set-Content -Path README.md
