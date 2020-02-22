# Returns Terraform Plan summary
# This script should ONLY return plan summary to StdOut
#
# IMPORTANT: when using "returnStdout: true" in Jenkins, you must ensure ONLY your desired value is output to the
# pipeline. DO NOT use Write-Output, Write-Host, or output anything else into the pipeline.
#
# If you are using the returnStdout option of the powershell Pipeline step then only stream 1 will be returned,
# while streams 2-6 will be redirected to the console output if you enable stream pref to "Continue"
# eg: $VerbosePreference = "Continue"
# Ref: https://jenkins.io/blog/2017/07/26/powershell-pipeline/

[CmdletBinding()]
param (
    [string] $TFDiffFilename = "diff.txt"
)

# Set prefs
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Change into TF folder location
Push-Location -Path .\terraform

# Check for planned changes in Terraform diff file
$message = "Checking for Terraform planned changes"
Write-Verbose "STARTED: $message..."
if ($output = Get-Content $TFDiffFilename | Select-String "Plan:.*add.*change.*destroy") {
    $output

    <#
    # Regex testing: https://regex101.com/

    EXPLANATION: ^\s*\+
    ^ asserts position at start of a line
    \s* matches any whitespace character (equal to [\r\n\t\f\v ])
    * Quantifier - Matches between zero and unlimited times, as many times as possible, giving back as needed (greedy)
    \+ matches the character + literally (case sensitive)
    #>
    (Get-Content $TFDiffFilename) | Select-String "^\s*~", "^\s*\+", "^\s*-"

} else {
    "[NOT FOUND]"
}

Write-Verbose "FINISHED: $message."

# Revert to previous folder location
Pop-Location
