# This script configures a Windows VM to use UK English settings and prepares it for sysprep. It sets the culture, system locale, home location, and keyboard layout to UK standards. It also modifies the default user profile registry settings to ensure new users get the correct locale settings. Finally, it creates an unattend.xml file to ensure that the settings persist through the sysprep process.

# 1. Quick Regional & Keyboard Setup (No Download Required)
Write-Host "Configuring UK Regional & Keyboard settings..." -ForegroundColor Cyan
Set-Culture en-GB
Set-WinSystemLocale en-GB
Set-WinHomeLocation -GeoId 242 # United Kingdom
Set-TimeZone -Id "GMT Standard Time"

# Force UK Keyboard for current session
$LanguageList = New-WinUserLanguageList -Language "en-GB"
Set-WinUserLanguageList -LanguageList $LanguageList -Force

# 2. Configure Registry for Multi-session (Default User Profile)
Write-Host "Applying settings to Default User Profile..." -ForegroundColor Cyan
$DefaultUserRegistry = "C:\Users\Default\NTUSER.DAT"
if (Test-Path $DefaultUserRegistry) {
    reg load HKU\DefaultUser $DefaultUserRegistry
    $RegPath = "HKU\DefaultUser\Control Panel\International"
    Set-ItemProperty -Path "Registry::$RegPath" -Name "Locale" -Value "00000809"
    Set-ItemProperty -Path "Registry::$RegPath" -Name "sShortDate" -Value "dd/MM/yyyy"
    reg unload HKU\DefaultUser
}

# 3. Create Unattend.xml for Sysprep persistence
# This tells Windows to use UK English for the final OS installation
Write-Host "Creating Unattend.xml..." -ForegroundColor Cyan
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
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>1</ProtectYourPC>
            </OOBE>
            <TimeZone>GMT Standard Time</TimeZone>
        </component>
    </settings>
</unattend>
"@

$unattendContent | Out-File -FilePath $unattendPath -Encoding UTF8

# 4. Final Sysprep Command
Write-Host "Starting Sysprep... The VM will shut down when finished." -ForegroundColor Yellow
Start-Process -FilePath "C:\Windows\System32\Sysprep\sysprep.exe" -ArgumentList "/oobe /generalize /shutdown /unattend:$unattendPath" -Wait
