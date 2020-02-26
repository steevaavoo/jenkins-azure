# Gets cert info
#
# Source: https://isc.sans.edu/forums/diary/Assessing+Remote+Certificates+with+Powershell/20645/
# CertInfo.ps1
#
# Written by: Rob VandenBrink
#
# Params: Site name or IP ($Hostname), Port ($Port)
Write-Host "Loading Get-CertInfo.ps1"

function Get-CertInfo {
    param (
        $Hostname,
        [int] $Port
    )

    try {
        $Conn = New-Object System.Net.Sockets.TcpClient($WebsiteURL, $WebsitePort)
        try {
            $Stream = New-Object System.Net.Security.SslStream($Conn.GetStream(), $false, {
                    param($sender, $certificate, $chain, $sslPolicyErrors)
                    return $true
                })
            $Stream.AuthenticateAsClient($Hostname)

            $Cert = $Stream.Get_RemoteCertificate()
            # $CN = (($cert.Subject -split "=")[1] -split ",")[0]
            $Cert
        } catch { throw $_ }
        finally { $Conn.close() }
    } catch {
        Write-Host "$ID $WebsiteURL " $_.exception.innerexception.message -ForegroundColor red
    }
}
