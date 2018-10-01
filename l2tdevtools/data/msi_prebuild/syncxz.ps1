# Script that synchronizes xz.
#
# Version: 20180314

$ExitSuccess = 0
$ExitFailure = 1

Function DownloadFile($Url, $Destination)
{
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

	$Client = New-Object Net.WebClient
	${Client}.DownloadFile(${Url}, ${Destination})
}

Function ExtractTarGz($Filename)
{
	$SevenZip = "C:\Program Files\7-Zip\7z.exe"

	If (-Not (Test-Path ${SevenZip}))
	{
		Write-Host "Missing 7z.exe." -foreground Red

		Exit ${ExitFailure}
	}
	# Run 7z twice first to extract the .gz then the .tar

	# PowerShell will raise NativeCommandError if 7z writes to stdout or stderr
	# therefore 2>&1 is added and the output is stored in a variable.
	# The leading & and single quotes are necessary to compensate for the spaces in the path.
	$Output = Invoke-Expression -Command "& '${SevenZip}' -y x ${Filename} 2>&1"

	$Filename = ${Filename}.TrimEnd(".gz")

	$Output = Invoke-Expression -Command "& '${SevenZip}' -y x ${Filename} 2>&1"

	Remove-Item -Path ${Filename} -Force
}

$Version = "5.2.3"
$Filename = "${pwd}\zx-${Version}.tar.gz"
$Url = "https://tukaani.org/xz/xz-${Version}.tar.gz"
$ExtractedPath = "xz-${Version}"
$DestinationPath = "..\xz"

If (Test-Path ${Filename})
{
	Remove-Item -Path ${Filename} -Force
}
DownloadFile -Url ${Url} -Destination ${Filename}

If (Test-Path ${ExtractedPath})
{
	Remove-Item -Path ${ExtractedPath} -Force -Recurse
}
ExtractTarGz -Filename ${Filename}

Remove-Item -Path ${Filename} -Force

If (Test-Path ${DestinationPath})
{
	Remove-Item -Path ${DestinationPath} -Force -Recurse
}
Move-Item ${ExtractedPath} ${DestinationPath}

