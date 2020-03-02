# Wait for AKS Loadbalancer IP to exist, then updates Pipeline variable
[CmdletBinding()]
param (
    [string]
    $AksResourceGroupName,

    [string]
    $AksClusterName,

    [switch]
    $UseAksAdmin,

    [int]
    $TimeoutSeconds = 1800, # 1800s = 30 mins

    [int]
    $RetryIntervalSeconds = 10
)

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

# Merge AKS cluster details into ~\.kube\config
$importAzAksCredentialSplat = @{
    ResourceGroupName = $AksResourceGroupName
    Name              = $AksClusterName
    Force             = $true
    Verbose           = $true
}
if ($UseAksAdmin.IsPresent) {
    $importAzAksCredentialSplat.Admin = $true
}
Import-AzAksCredential @importAzAksCredentialSplat

# Wait for Loadbalancer IP to exist
$timer = [Diagnostics.Stopwatch]::StartNew()

while (-not ($dnsIpAddress = kubectl get svc nginxdemo --ignore-not-found -o jsonpath="{.status.loadBalancer.ingress[0].ip}")) {

    if ($timer.Elapsed.TotalSeconds -gt $TimeoutSeconds) {
        Write-Verbose "Elapsed task time of [$($timer.Elapsed.TotalSeconds)] has exceeded timeout of [$TimeoutSeconds]"
        exit 1
    } else {
        Write-Verbose "Current Loadbalancer IP value: [$dnsIpAddress]"
        Write-Verbose "Still creating LoadBalancer IP... [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s elapsed]"
        Start-Sleep -Seconds $RetryIntervalSeconds
    }
}

$timer.Stop()

# Update pipeline variable
Write-Verbose "Creation complete after [$($timer.Elapsed.Minutes)m$($timer.Elapsed.Seconds)s]"
Write-Output $dnsIpAddress
