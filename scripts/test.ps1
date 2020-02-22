# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

Write-Output "Started in folder: [$(Get-Location)]"
Write-Output "Changing directory to test folder..."
Set-Location "test"
Write-Output "STARTED: pwsh test tasks in current folder: [$(Get-Location)]"

# Debug
if ($env:CI_DEBUG -eq "true") { Get-ChildItem env: | Select-Object "Name", "Value" }

# Tests
$taskMessage = "Running Pester tests"
Write-Output -Message "STARTED: $taskMessage..."
try {
    $testScripts = Get-ChildItem -Path "*.tests.ps1"
    Invoke-Pester -Script $testScripts -PassThru -OutputFormat "JUnitXml" -OutputFile "pester-test-results-junit.xml" -Verbose -ErrorAction "Stop"

    Write-Output -Message "FINISHED: $taskMessage."
}
catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction "Continue"
    throw
}

Write-Output "FINISHED: pwsh test tasks"
