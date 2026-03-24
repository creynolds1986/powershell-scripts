# This script configures a Windows VM to use UK English settings and prepares it for sysprep. It sets the culture, system locale, home location, and keyboard layout to UK standards. It also modifies the default user profile registry settings to ensure new users get the correct locale settings. Finally, it creates an unattend.xml file to ensure that the settings persist through the sysprep process.

# 1. Disable BitLocker and Wait for Decryption
$drive = Get-BitLockerVolume -MountPoint "C:"
if ($drive.VolumeStatus -ne "FullyDecrypted") {
    Write-Host "BitLocker is active ($($drive.VolumeStatus)). Starting decryption..." -ForegroundColor Yellow
    Disable-BitLocker -MountPoint "C:"
    
    # Wait until fully decrypted so Sysprep doesn't trip over it
    while ((Get-BitLockerVolume -MountPoint "C:").VolumeStatus -ne "Decrypted") {
        Write-Host "Waiting for decryption to finish... (Checking every 10s)" -ForegroundColor Cyan
        Start-Sleep -Seconds 10
    }
    Write-Host "Drive successfully decrypted." -ForegroundColor Green
}

# 2. Regional & Keyboard Setup (UK English)
Write-Host "Setting UK Regional and Keyboard defaults..." -ForegroundColor Cyan
Set-Culture en-GB
Set-WinSystemLocale en-GB
Set-WinHomeLocation -GeoId 242
Set-TimeZone -Id "GMT Standard Time"
$LanguageList = New-WinUserLanguageList -Language "en-GB"
Set-WinUserLanguageList -LanguageList $LanguageList -Force

# 3. Apply to Default User Profile (for Multi-session users)
$DefaultUserRegistry = "C:\Users\Default\NTUSER.DAT"
if (Test-Path $DefaultUserRegistry) {
    reg load HKU\DefaultUser $DefaultUserRegistry
    $RegPath = "HKU\DefaultUser\Control Panel\International"
    Set-ItemProperty -Path "Registry::$RegPath" -Name "Locale" -Value "00000809"
    Set-ItemProperty -Path "Registry::$RegPath" -Name "sShortDate" -Value "dd/MM/yyyy"
    reg unload HKU\DefaultUser
}

# 4. Create Unattend.xml
$unattendPath = "C:\Windows\System32\Sysprep\unattend.xml"
$unattendContent = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>0809:00000809</InputLocale>
            <SystemLocale>en-GB</SystemLocale>
            <UILanguage>en-GB</UILanguage>
            <UserLocale>en-GB</UserLocale>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>0809:00000809</InputLocale>
            <SystemLocale>en-GB</SystemLocale>
            <UILanguage>en-GB</UILanguage>
            <UserLocale>en-GB</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>1</ProtectYourPC>
            </OOBE>
            <TimeZone>GMT Standard Time</TimeZone>
        </component>
    </settings>
</unattend>
"@
$unattendContent | Out-File -FilePath $unattendPath -Encoding UTF8

# 5. Final Sysprep Command
Write-Host "Starting Sysprep. The VM will shut down upon completion." -ForegroundColor Yellow
Start-Process -FilePath "C:\Windows\System32\Sysprep\sysprep.exe" -ArgumentList "/oobe /generalize /shutdown /unattend:$unattendPath"
