Import-Module -Name AWS.Tools.SimpleSystemsManagement, SimplySql

Set-DefaultAWSRegion -Region us-west-2

$Filter = [Amazon.SimpleSystemsManagement.Model.DocumentKeyValuesFilter]::new()
$Filter.Key = 'Owner'
$Filter.Values = 'Public'

$ScriptDate = Get-Date
$TargetFolder = 'documents/{0}' -f (Get-Date -Format 'yyyy/MM/dd')

# Create directory for files, if it doesn't exist.
New-Item -ItemType Directory -Path $ScriptDate -ErrorAction Ignore

$DocList = Get-SSMDocumentList -Filter $Filter

foreach ($Document in $DocList) {
  $CurrentDocument = Get-SSMDocument -Name $Document.Name -DocumentVersion $Document.DocumentVersion
  $FileName = '{0}/{1}-{2}-{3}.json' -f $TargetFolder, $Document.Owner, $CurrentDocument.Name.Split('/')[-1], $Document.DocumentVersion
  $CurrentDocument | ConvertTo-Json -Depth 10 | Set-Content -Path $FileName
}
