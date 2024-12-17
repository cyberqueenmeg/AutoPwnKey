; Define the output file path
outputFilePath := A_ScriptDir "\output.txt"
FileDelete(outputFilePath) ; Delete the file if it already exists

; PowerShell script content
psScript :=
"function Test-Port {" & "`n" &
"    param (" & "`n" &
"        [string]$TargetHost," & "`n" &
"        [int]$Port" & "`n" &
"    )" & "`n" &
"    try {" & "`n" &
"        $tcpClient = New-Object System.Net.Sockets.TcpClient" & "`n" &
"        $tcpClient.Connect($TargetHost, $Port)" & "`n" &
"        $tcpClient.Close()" & "`n" &
"        return $true" & "`n" &
"    } catch {" & "`n" &
"        return $false" & "`n" &
"    }" & "`n" &
"}" & "`n" &
"" & "`n" &
"function Get-LocalNetworks {" & "`n" &
"    $networkInterfaces = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }" & "`n" &
"    $networks = @()" & "`n" &
"    foreach ($interface in $networkInterfaces) {" & "`n" &
"        if ($interface.IPAddress -ne $null -and $interface.IPSubnet -ne $null -and $interface.DefaultIPGateway -ne $null) {" & "`n" &
"            $network = New-Object PSObject -Property @{" & "`n" &
"                'Name' = $interface.Description" & "`n" &
"                'IPAddress' = $interface.IPAddress[0]" & "`n" &
"                'SubnetMask' = $interface.IPSubnet[0]" & "`n" &
"                'Gateway' = $interface.DefaultIPGateway[0]" & "`n" &
"            }" & "`n" &
"            $networks += $network" & "`n" &
"        }" & "`n" &
"    }" & "`n" &
"    return $networks" & "`n" &
"}" & "`n" &
"" & "`n" &
"# Define the output file path" & "`n" &
"$outputFilePath = '" outputFilePath "'" & "`n" &
"Remove-Item $outputFilePath -ErrorAction Ignore" & "`n" &
"" & "`n" &
"# Get local networks" & "`n" &
"$localNetworks = Get-LocalNetworks" & "`n" &
"" & "`n" &
"# Check if there are any active network interfaces" & "`n" &
"if ($localNetworks) {" & "`n" &
"    foreach ($network in $localNetworks) {" & "`n" &
"        $output = 'Scanning network interface: ' + $network.Name + '`n'" & "`n" &
"        Add-Content -Path $outputFilePath -Value $output" & "`n" &
"        $targetIP = $network.IPAddress" & "`n" &
"        $openPorts = @()" & "`n" &
"        $portsToScan = 21,22,25,80,443,135,137,139,3389,8080,9000  # You can change the range of ports to scan here" & "`n" &
"        foreach ($port in $portsToScan) {" & "`n" &
"            $isOpen = Test-Port -TargetHost $targetIP -Port $port" & "`n" &
"            if ($isOpen) {" & "`n" &
"                $openPorts += $port" & "`n" &
"            }" & "`n" &
"        }" & "`n" &
"        $output = 'Host: ' + $targetIP + ', Open Ports: ' + ($openPorts -join ', ') + '`n'" & "`n" &
"        Add-Content -Path $outputFilePath -Value $output" & "`n" &
"    }" & "`n" &
"} else {" & "`n" &
"    Add-Content -Path $outputFilePath -Value 'No active network interfaces found. It seems you''re stranded in the network void!'" & "`n" &
"}"

; Save the PowerShell script to a temporary file
psFile := A_Temp "\network_scan.ps1"
FileDelete(psFile) ; Delete the file if it already exists
FileAppend(psScript, psFile, "UTF-8")

; Run the PowerShell script hidden
RunWait("powershell -ExecutionPolicy Bypass -File " psFile, "", "Hide")

; Clean up the temporary PowerShell script file
FileDelete(psFile)

; Check if the output file was created
if FileExist(outputFilePath)
    MsgBox("Success", "Network scan results have been written to " outputFilePath)
else
    MsgBox("Error", "Failed to write network scan results to " outputFilePath)
