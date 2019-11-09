# Replace tokens
$targetFilePattern = './terraform/*.tf'
$tokenPrefix = '__'
$tokenSuffix = '__'

# Prepare env vars
$envVarHash = @{ }
foreach ($envvar in (Get-ChildItem env:)) {
    $envVarHash.Add("$($tokenPrefix)$($envvar.Name)$($tokenSuffix)", $envvar.Value)
}

# Get files
$targetFiles = (Get-ChildItem -Path $targetFilePattern)

# Replace tokens
foreach ($targetFile in $targetFiles) {
    foreach ($item in $replaceHash.GetEnumerator()) {
        ((Get-Content -Path $targetFile -Raw) -replace $item.key, $item.value) | Set-Content -Path $targetFile
    }
}
