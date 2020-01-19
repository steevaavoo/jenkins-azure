<#
.SYNOPSIS
    Waits for a Load Balancer Ingress IP then uses it to update a DNS A record
.DESCRIPTION
    Waits for a Load Balancer Ingress IP then uses it to update a DNS A record
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
    $AksResourceGroupName,
    $AksClusterName,
    $UseAksAdmin,
    $TimeoutSeconds = 1800, # 1800s = 30 mins
    $RetryIntervalSeconds = 10,
    $DomainName,
    $ApiKey,
    $ApiSecret,
    $Ttl = 600,
    $ServiceName = 'nodeapp'
)

$ErrorActionPreference = "Stop"

# Setting k8s current context
az aks get-credentials --resource-group $env:AKS_RG_NAME --name $env:AKS_CLUSTER_NAME --overwrite-existing

# Wait for Loadbalancer IP to exist
$timer = [Diagnostics.Stopwatch]::StartNew()

while (-not ($IPAddress = kubectl get svc $ServiceName --ignore-not-found -o jsonpath="{.status.loadBalancer.ingress[0].ip}")) {

    if ($timer.Elapsed.TotalSeconds -gt $TimeoutSeconds) {
        Write-Host "Elapsed task time of [$($timer.Elapsed.TotalSeconds)] has exceeded timeout of [$TimeoutSeconds]"
        exit 1
    } else {
        Write-Host "Current Loadbalancer IP value: [$IPAddress]"
        Write-Host "Still creating LoadBalancer IP... [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s elapsed]"
        Start-Sleep -Seconds $RetryIntervalSeconds
    }
}

$timer.Stop()

# Update pipeline variable
Write-Host "Creation complete after [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s]"
Write-Host "Found IP [$IPAddress]"

# Init
Install-Module -Name "Trackyon.GoDaddy"-Scope "CurrentUser" -Force
$apiCredential = [pscredential]::new($ApiKey, (ConvertTo-SecureString -String $ApiSecret -AsPlainText -Force))

# Output Domain
Get-GDDomain -credentials $apiCredential -domain $DomainName | Out-String | Write-Output

# Output current records
Get-GDDomainRecord -credentials $apiCredential -domain $DomainName | Out-String | Write-Output

# Update A record
$message = "Updating domain [$DomainName] with IP Address [$IPAddress]"
Write-Host "STARTED: $message"
Set-GDDomainRecord -credentials $apiCredential -domain $DomainName -name '@' -ipaddress $IPAddress -type "A" -ttl $Ttl -Force
Write-Host "FINISHED: $message"

# Output updated records
Get-GDDomainRecord -credentials $apiCredential -domain $DomainName | Out-String | Write-Output