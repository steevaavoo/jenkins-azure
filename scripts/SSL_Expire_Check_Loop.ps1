# Script: SSL_Epire_Check_Loop.ps1
# Version: 1.4.3
# Notes: Original Version Found Here: https://stackoverflow.com/questions/28386579/modifying-ssl-cert-check-powershell-script-to-loop-through-multiple-sites#_=_
# Refined By: Ben Personick
#
$WebsiteURLs = @("aks.thehypepipe.co.uk")
$WebsitePort = 443
$Threshold = 120
$Severe = 30
$ID = 0
Write-Host "# Website_URL: Current Certificate: Expiration Date: Days Remaining: Errors:"
foreach ($WebsiteURL in $WebsiteURLs) {
    $CommonName = $WebsiteURL
    $ID += 1
    Try {
        $Conn = New-Object System.Net.Sockets.TcpClient($WebsiteURL, $WebsitePort)
        Try {
            $Stream = New-Object System.Net.Security.SslStream($Conn.GetStream(), $false, {
                    param($sender, $certificate, $chain, $sslPolicyErrors)
                    return $true
                })
            $Stream.AuthenticateAsClient($CommonName)

            $Cert = $Stream.Get_RemoteCertificate()
            $CN = (($cert.Subject -split "=")[1] -split ",")[0]
            $ValidTo = [datetime]::Parse($Cert.GetExpirationDatestring())

            $ValidDays = $($ValidTo - [datetime]::Now).Days
            $MyFontColor = "darkgreen"
            if ($ValidDays -lt $Threshold) {
                $MyFontColor = "darkyellow"
            }
            if ($ValidDays -lt $Severe) {
                $MyFontColor = "red"
            }
            Write-Host "$ID $WebsiteURL $CN $ValidTo $ValidDays" -ForegroundColor $MyFontColor
        } Catch { Throw $_ }
        Finally { $Conn.close() }
    } Catch {
        Write-Host "$ID $WebsiteURL " $_.exception.innerexception.message -ForegroundColor red
    }

}
