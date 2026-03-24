# This script configures a Windows image to use UK English as the default language and regional settings, and prepares it for sysprep with an unattend.xml file to ensure these settings persist across user sessions.

# 1. Install UK Language Pack and Set Regional Defaults
Write-Host "Installing UK English Language Pack..." -ForegroundColor Cyan
Install-Language en-GB
Set-SystemPreferredUILanguage en-GB
Set-Culture en-GB
Set-WinSystemLocale en-GB
Set-WinHomeLocation -GeoId 242 # 242 is United Kingdom
Set-WinUserLanguageList -LanguageList en-GB -Force
Set-TimeZone -Id "GMT Standard Time"

# 2. Configure Registry for Default User Profile (Multi-session Support)
Write-Host "Configuring Default User Profile for UK Locale..." -ForegroundColor Cyan
$DefaultUserRegistry = "C:\Users\Default\NTUSER.DAT"
reg load HKU\DefaultUser $DefaultUserRegistry
$RegPath = "HKU\DefaultUser\Control Panel\International"
Set-ItemProperty -Path "Registry::$RegPath" -Name "Locale" -Value "00000809"
Set-ItemProperty -Path "Registry::$RegPath" -Name "sShortDate" -Value "dd/MM/yyyy"
reg unload HKU\DefaultUser

# 3. Create Unattend.xml for Sysprep persistence
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
Write-Host "Starting Sysprep and Shutting Down..." -ForegroundColor Yellow
Start-Process -FilePath "C:\Windows\System32\Sysprep\sysprep.exe" -ArgumentList "/oobe /generalize /shutdown /unattend:$unattendPath" -Wait
