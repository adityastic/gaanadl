<#
.SYNOPSIS
This is a simple Powershell script to install and update FFMPEG from official sources

.DESCRIPTION
The script will download based on the detected architecture of the host and the channel selected the newest version it can find from the FFMPEG official static releases.

.EXAMPLE
Update-FFMPEG.ps1
Update FFMPEG using the default parameters in which it will download the latest Nightly build and will automatically detect your host systems architecture

.EXAMPLE
Update-FFMPEG.ps1 -Channel Stable
Update or install FFMPEG using the stable release channel

.EXAMPLE
Update-FFMPEG.ps1 -Channel Stable -Architecture 32
Update or install FFMPEG using the stable release channel and instead of auto detection of the architecture it will download the 32 bit version

.EXAMPLE
Update-FFMPEG.ps1 -FFMPEGPath "C:\ffmpeg\"
Update of install FFMPEG using a specific update or installation location instead of the default

.EXAMPLE
Update-FFMPEG.ps1 -AddEnvironmentVariable
Update or install FFMPEG using the default parameters and add it self to the User Environment Variables

.LINK
https://www.ffmpeg.org/
#>

[CmdletBinding()]
param
(
    [Parameter()][ValidateSet('Stable', 'Nightly')][string]$Channel = "Stable",
    [Parameter()][ValidateSet('64', '32', 'Detect')][string]$Architecture = "Detect",
    [Parameter()][String]$FFMPEGPath = "C:\ffmpeg\",
    [Parameter()][Switch]$AddEnvironmentVariable = $true
)

#General Declares in the Program
$SaveFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-update.zip"
$ExtractFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-update"

#If Architecture is set to Detect then detect and set it
if ($Architecture -eq 'Detect')
{
    Write-Verbose "Detecting host operating system architecture to download according version of FFMPEG"
    if ([Environment]::Is64BitOperatingSystem)
    {
        $Architecture = '64'
    }
    else
    {
        $Architecture = '32'
    }
}

#Request the static files available for download based on Architecture and Channel
$Request = Invoke-WebRequest -Uri ("https://ffmpeg.zeranoe.com/builds/win" + $Architecture + "/static/?C=M&O=D")
if ($Channel -eq 'Nightly')
{
    $DownloadFFMPEGStatic = ("https://ffmpeg.zeranoe.com/builds/win" + $Architecture + "/static/" + (($Request.Links | Select-Object -ExpandProperty href | Where-Object Length -eq 40)[0]))
}
else
{
    $DownloadFFMPEGStatic = ("https://ffmpeg.zeranoe.com/builds/win" + $Architecture + "/static/" + (($Request.Links | Select-Object -ExpandProperty href | Where-Object Length -eq 29)[0]).ToString())
}
$ExtractedFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-update\" + ($DownloadFFMPEGStatic.Split('/')[-1].Replace('.zip', '')) + "\"

#Detection if ffmpeg is running and if so kill it
Write-Verbose "Detecting if FFMPEG is already running"
if (Get-Process ffmpeg -ErrorAction SilentlyContinue)
{
    Write-Verbose "Shutting down FFMPEG"
    Get-Process ffmpeg | Stop-Process ffmpeg -Force
}

#Check if the FFMPEG Path in C:\ exists if not create it
Write-Verbose "Detecting if FFMPEG directory already exists"
If (-Not (Test-Path $FFMPEGPath))
{
    Write-Verbose "Creating FFMPEG directory"
    New-Item -Path $FFMPEGPath -ItemType Directory | Out-Null
}
else
{
    Get-ChildItem $FFMPEGPath | Remove-item -Recurse -Confirm:$false
}

#Download based on the channel input which ffmpeg download you want
Write-Verbose "Downloading the selected FFMPEG application zip"
Invoke-WebRequest $DownloadFFMPEGStatic -OutFile $SaveFFMPEGTempLocation

#Unzip the downloaded archive to a temp location
Write-Verbose "Expanding the downloaded FFMPEG application zip"
Expand-Archive $SaveFFMPEGTempLocation -DestinationPath $ExtractFFMPEGTempLocation

#Copy from temp location to $FFMPEGPath
Write-Verbose "Retrieving and installing new FFMPEG files"
Get-ChildItem $ExtractedFFMPEGTempLocation | Copy-Item -Destination $FFMPEGPath -Recurse -Force

#Add to the PATH Environment Variables
if ($AddEnvironmentVariable)
{
    Write-Verbose "Adding the FFMPEG bin folder to the User Environment Variables"
    [Environment]::SetEnvironmentVariable("PATH", ($FFMPEGPath + "bin"), "User")
}

#Clean up of files that were used
Write-Verbose "Clean up of the downloaded FFMPEG zip package"
if (Test-Path ($SaveFFMPEGTempLocation))
{
    Remove-Item $SaveFFMPEGTempLocation -Confirm:$false
}

#Clean up of files that were used
Write-Verbose "Clean up of the expanded FFMPEG zip package"
if (Test-Path ($ExtractFFMPEGTempLocation))
{
    Remove-Item $ExtractFFMPEGTempLocation -Recurse -Confirm:$false
}