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
        $conn = New-Object System.Net.Sockets.TcpClient($Hostname, $Port)
        try {
            $stream = New-Object System.Net.Security.SslStream($conn.GetStream(), $false, {
                    param($sender, $certificate, $chain, $sslPolicyErrors)
                    return $true
                })
            $stream.AuthenticateAsClient($Hostname)

            $cert = $stream.Get_RemoteCertificate()
            # $CN = (($cert.Subject -split "=")[1] -split ",")[0]
            $cert
        } catch { throw $_ }
        finally { $conn.close() }
    } catch {
        Write-Host "$ID $Hostname " $_.exception.innerexception.message -ForegroundColor red
    }
}
