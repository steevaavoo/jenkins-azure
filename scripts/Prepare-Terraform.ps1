# Replace tokens
$targetFilePattern = './terraform/*.tf'
$tokenPrefix = '__'
$tokenSuffix = '__'

# Prepare env vars
$envVarHash = @{ }
foreach ($envvar in (Get-ChildItem env:)) {
    $envVarHash.Add("$($tokenPrefix)$($envvar.Name)$($tokenSuffix)", $envvar.Value)
}

$envVarHash

# Get files
$targetFiles = (Get-ChildItem -Path $targetFilePattern)

# Replace tokens
foreach ($targetFile in $targetFiles) {
    foreach ($item in $envVarHash.GetEnumerator()) {
        ((Get-Content -Path $targetFile -Raw) -replace $item.key, $item.value) | Set-Content -Path $targetFile
    }
}

# Add env vars for Terraform
$env:ARM_SUBSCRIPTION_ID = $env:AZURE_SUBSCRIPTION_ID
$env:ARM_CLIENT_ID = $env:AZURE_CLIENT_ID
$env:ARM_CLIENT_SECRET = $env:AZURE_CLIENT_SECRET
$env:ARM_TENANT_ID = $env:AZURE_TENANT_ID
