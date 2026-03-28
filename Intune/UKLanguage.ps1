# This script should be added as a Powershell script in Intune and run in the user context. Set the signature check to no. Assign it to a group of users or all users.
# Sets the active user's culture and language to UK
Set-Culture en-GB
Set-WinSystemLocale -SystemLocale en-GB
Set-WinUserLanguageList -LanguageList "en-GB" -Force

# Force the taskbar clock to refresh immediately
$signature = '[DllImport("user32.dll")] public static extern IntPtr PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);'
$type = Add-Type -MemberDefinition $signature -Name "NativeMethods" -Namespace "Win32" -PassThru
$type::PostMessage(0xffff, 0x001a, 0, 0)