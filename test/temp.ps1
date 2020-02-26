

# Vars
$hostname = $env:DNS_DOMAIN_NAME
$port = 443
# Number of days out to warn about certificate expiration
$warningThreshold = 14

switch ($env:CERT_API_ENVIRONMENT) {
    prod { $expectedIssuerName = "Let's Encrypt Authority" }
    staging { $expectedIssuerName = "Fake LE Intermediate" }
    Default { $expectedIssuerName = "NOT DEFINED" }
}

# Get cert
. ../scripts/Test-SslProtocol.ps1
$sslResult = Test-SslProtocol -ComputerName $hostname -Port $port

# DEBUG Output
if ($env:CI_DEBUG -eq "true") { $sslResult | Format-List * }
