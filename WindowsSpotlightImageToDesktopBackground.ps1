[CmdletBinding()]
param()

function GetWindowsSpotlightLandscapeImageFilePath
{
    # Get the registry key of landscapeImage value.
    $userSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $landscapeImageRegBaseKey = ('Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\{0}' -f $userSid)
    $landscapeImageRegKey = Get-ChildItem -LiteralPath $landscapeImageRegBaseKey |
                                Sort-Object -Property 'PSChildName' -Descending |
                                Select-Object -First 1

    # Get the Windows Spotlight landscape image file path.
    $windowsSpotlightImageFilePath = $landscapeImageRegKey.GetValue('landscapeImage')

    $windowsSpotlightImageFilePath
}

function ChangeDesktopWallpaler
{
    param (
        [string] $WallpaperIamgeFilePath
    )

    if (-not ([System.Management.Automation.PSTypeName]'DesktopWallpaperHelper').Type)
    {
        # Add helper class.
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class DesktopWallpaperHelper
{
    internal static class NativeMethods
    {
        public const uint SPI_SETDESKWALLPAPER = 0x0014;
        public const uint SPIF_UPDATEINIFILE = 0x01;
        public const uint SPIF_SENDWININICHANGE = 0x02;

        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
    }


    public static bool ChangeDesktopWallpaler(string wallpaperIamgeFilePath)
    {
        return NativeMethods.SystemParametersInfo(NativeMethods.SPI_SETDESKWALLPAPER, 0, wallpaperIamgeFilePath, NativeMethods.SPIF_UPDATEINIFILE | NativeMethods.SPIF_SENDWININICHANGE);
    }
}
'@
    }

    [DesktopWallpaperHelper]::ChangeDesktopWallpaler($WallpaperIamgeFilePath)
}


# Get the Windows Spotlight landscape image file path.
$windowsSpotlightImageFilePath = GetWindowsSpotlightLandscapeImageFilePath
Write-Verbose -Message ('Windows Spotloght image: {0}' -f $windowsSpotlightImageFilePath)

# Change the desktop background image.
if (ChangeDesktopWallpaler -WallpaperIamgeFilePath $windowsSpotlightImageFilePath)
{
    Write-Verbose -Message 'Wallpaper changed to Windows Spotlight image.'
}
else
{
    Write-Verbose -Message 'Failed change of wallpaper.'
}
