# This script is for single use Windows 11 VMs or physical devices.
# It configures the system to use UK English settings and prepares it for sysprep, which is necessary for creating a reusable image. 
# The script ensures that the culture, system locale, home location, and keyboard layout are set to UK standards.
# It also modifies the default user profile registry settings to ensure that any new users created on the system will have the correct locale settings.
# Finally, it creates an unattend.xml file that specifies the regional settings to be applied during the sysprep process, ensuring that these settings persist when the image is deployed to new VMs or used on physical hardware.

# ── 1. BitLocker ──
try {
    $drive = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
    if ($drive.VolumeStatus -ne "FullyDecrypted") {
        Write-Host "BitLocker active. Decrypting..." -ForegroundColor Yellow
        Disable-BitLocker -MountPoint "C:"
        while ((Get-BitLockerVolume -MountPoint "C:").VolumeStatus -ne "FullyDecrypted") {
            Write-Host "Waiting for decryption..." -ForegroundColor Cyan
            Start-Sleep -Seconds 10
        }
        Write-Host "Decryption complete." -ForegroundColor Green
    }
} catch {
    Write-Host "BitLocker not present or not applicable — skipping." -ForegroundColor Gray
}

# ── 2. Regional & Keyboard (UK English) ──
Write-Host "Applying UK regional settings..." -ForegroundColor Cyan
Set-Culture en-GB
Set-WinSystemLocale en-GB
Set-WinHomeLocation -GeoId 242
Set-TimeZone -Id "GMT Standard Time"
$langList = New-WinUserLanguageList -Language "en-GB"
Set-WinUserLanguageList -LanguageList $langList -Force

# ── 3. Default User Profile registry ──
$defaultHive = "C:\Users\Default\NTUSER.DAT"
if (Test-Path $defaultHive) {
    reg load HKU\DefaultUser $defaultHive | Out-Null
    $regPath = "Registry::HKU\DefaultUser\Control Panel\International"
    Set-ItemProperty -Path $regPath -Name "Locale"      -Value "00000809"
    Set-ItemProperty -Path $regPath -Name "sShortDate"  -Value "dd/MM/yyyy"
    Set-ItemProperty -Path $regPath -Name "sLongDate"   -Value "dd MMMM yyyy"
    Set-ItemProperty -Path $regPath -Name "sTimeFormat" -Value "HH:mm:ss"

    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    reg unload HKU\DefaultUser | Out-Null
}

# ── 4. Unattend.xml (specialize + oobeSystem for single-user) ──
$unattendPath = "C:\Windows\System32\Sysprep\unattend.xml"

$unattendContent = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-International-Core"
                   processorArchitecture="amd64"
                   publicKeyToken="31bf3856ad364e35"
                   language="neutral"
                   versionScope="nonSxS"
                   xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <InputLocale>0809:00000809</InputLocale>
            <SystemLocale>en-GB</SystemLocale>
            <UILanguage>en-GB</UILanguage>
            <UserLocale>en-GB</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup"
                   processorArchitecture="amd64"
                   publicKeyToken="31bf3856ad364e35"
                   language="neutral"
                   versionScope="nonSxS"
                   xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <TimeZone>GMT Standard Time</TimeZone>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core"
                   processorArchitecture="amd64"
                   publicKeyToken="31bf3856ad364e35"
                   language="neutral"
                   versionScope="nonSxS"
                   xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <InputLocale>0809:00000809</InputLocale>
            <SystemLocale>en-GB</SystemLocale>
            <UILanguage>en-GB</UILanguage>
            <UserLocale>en-GB</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup"
                   processorArchitecture="amd64"
                   publicKeyToken="31bf3856ad364e35"
                   language="neutral"
                   versionScope="nonSxS"
                   xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>3</ProtectYourPC>
            </OOBE>
            <TimeZone>GMT Standard Time</TimeZone>
        </component>
    </settings>
</unattend>
"@

[System.IO.File]::WriteAllText($unattendPath, $unattendContent, [System.Text.UTF8Encoding]::new($false))
Write-Host "unattend.xml written to $unattendPath" -ForegroundColor Green

# ── 5. Sysprep ──
Write-Host "Running sysprep — VM will shut down on completion." -ForegroundColor Yellow
Start-Process -FilePath "C:\Windows\System32\Sysprep\sysprep.exe" `
              -ArgumentList "/generalize /oobe /shutdown /unattend:`"$unattendPath`"" `
              -Wait
