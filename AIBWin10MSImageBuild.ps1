#Script to setup golden image with Azure Image Builder


#Create temp folder
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null

#Create Deprovisioner script for sysprep
New-Item -Path 'c:\DeprovisioningScript.ps1' -ItemType File -Force | Out-Null
add-content 'c:\DeprovisioningScript.ps1' "Write-Output '>>> Waiting for GA Service (RdAgent) to start ...'"
add-content 'c:\DeprovisioningScript.ps1' "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }"
add-content 'c:\DeprovisioningScript.ps1' "Write-Output '>>> Waiting for GA Service (WindowsAzureTelemetryService) to start ...'"
add-content 'c:\DeprovisioningScript.ps1' "while ((Get-Service WindowsAzureTelemetryService) -and ((Get-Service WindowsAzureTelemetryService).Status -ne 'Running')) { Start-Sleep -s 5 }"
add-content 'c:\DeprovisioningScript.ps1' "Write-Output '>>> Waiting for GA Service (WindowsAzureGuestAgent) to start ...'"
add-content 'c:\DeprovisioningScript.ps1' "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }"
add-content 'c:\DeprovisioningScript.ps1' "Write-Output '>>> Sysprepping VM ...'"
add-content 'c:\DeprovisioningScript.ps1' "if( Test-Path $Env:SystemRoot\system32\Sysprep\unattend.xml ) {"
add-content 'c:\DeprovisioningScript.ps1' "Remove-Item $Env:SystemRoot\system32\Sysprep\unattend.xml -Force"
add-content 'c:\DeprovisioningScript.ps1' "}"
add-content 'c:\DeprovisioningScript.ps1' "& $Env:SystemRoot\System32\Sysprep\Sysprep.exe /oobe /generalize /quiet /quit"
add-content 'c:\DeprovisioningScript.ps1' "while($true) {"
add-content 'c:\DeprovisioningScript.ps1' "$imageState = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State).ImageState"
add-content 'c:\DeprovisioningScript.ps1' "Write-Output $imageState"
add-content 'c:\DeprovisioningScript.ps1' "if ($imageState -eq 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { break }"
add-content 'c:\DeprovisioningScript.ps1' "Start-Sleep -s 5"
add-content 'c:\DeprovisioningScript.ps1' "}"
add-content 'c:\DeprovisioningScript.ps1' "Write-Output '>>> Sysprep complete ...'"

#Install VSCode
Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?Linkid=852157' -OutFile 'c:\temp\VScode.exe'
Invoke-Expression -Command 'c:\temp\VScode.exe /verysilent'

#Start sleep
Start-Sleep -Seconds 10

#InstallNotepadplusplus
Invoke-WebRequest -Uri 'https://notepad-plus-plus.org/repository/7.x/7.7.1/npp.7.7.1.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Invoke-Expression -Command 'c:\temp\notepadplusplus.exe /S'

#Start sleep
Start-Sleep -Seconds 10

#InstallFSLogix
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Start-Sleep -Seconds 10
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'

#Start sleep
Start-Sleep -Seconds 10

#InstallTeamsMachinemode
New-Item -Path 'HKLM:\SOFTWARE\Citrix\PortICA' -Force | Out-Null
Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&download=true&managedInstaller=true&arch=x64' -OutFile 'c:\temp\Teams.msi'
Invoke-Expression -Command 'msiexec /i C:\temp\Teams.msi /quiet /l*v C:\temp\teamsinstall.log ALLUSER=1'
Start-Sleep -Seconds 30
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32 -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force
