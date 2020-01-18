<#
.SYNOPSIS
    Updates a DNS A record with a new IP address
.DESCRIPTION
    Updates a DNS A record with a new IP address using the GoDaddy PowerShell module
.LINK
    https://www.powershellgallery.com/packages/Trackyon.GoDaddy
.NOTES
    Author:  Adam Rush
    Blog:    https://adamrushuk.github.io
    GitHub:  https://github.com/adamrushuk
    Twitter: @adamrushuk
#>

[CmdletBinding()]
param (
    $DomainName,
    $IPAddress,
    $ApiKey,
    $ApiSecret,
    $Ttl = 600
)

# Init
Install-Module -Name "Trackyon.GoDaddy"-Scope "CurrentUser" -Force
$apiCredential = [pscredential]::new($ApiKey, (ConvertTo-SecureString -String $ApiSecret -AsPlainText -Force))

# Output Domain
Get-GDDomain -credentials $apiCredential -domain $DomainName | Out-String | Write-Output

# Output current records
Get-GDDomainRecord -credentials $apiCredential -domain $DomainName | Out-String | Write-Output

# Update A record
$message = "Updating domain [$DomainName] with IP Address [$IPAddress]"
Write-Output "STARTED: $message"
Set-GDDomainRecord -credentials $apiCredential -domain $DomainName -name '@' -ipaddress $IPAddress -type "A" -ttl $Ttl -Force
Write-Output "FINISHED: $message"

# Output updated records
Get-GDDomainRecord -credentials $apiCredential -domain $DomainName | Out-String | Write-Output