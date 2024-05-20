# Script that builds dokan
#
# Version: 20180322

Param (
	[string]$Configuration = ${Env:Configuration},
	[string]$Platform = ${Env:Platform},
	[switch]$UseLegacyVersion = $false,
	[string]$VisualStudioVersion = ""
)

If (-not ${Configuration})
{
	$Configuration = "Release"
}
If (-not ${Platform})
{
	$Platform = "Win32"
}

If (-Not ${VisualStudioVersion})
{
	$VisualStudioVersion = "2022"

	Write-Host "Visual Studio version not set defauting to: ${VisualStudioVersion}" -foreground Red
}
If ((${VisualStudioVersion} -ne "2008") -And (${VisualStudioVersion} -ne "2010") -And (${VisualStudioVersion} -ne "2012") -And (${VisualStudioVersion} -ne "2013") -And (${VisualStudioVersion} -ne "2015") -And (${VisualStudioVersion} -ne "2017") -And (${VisualStudioVersion} -ne "2019") -And (${VisualStudioVersion} -ne "2022"))
{
	Write-Host "Unsupported Visual Studio version: ${VisualStudioVersion}" -foreground Red

	Exit ${ExitFailure}
}

$MSBuild = ""
If (${Env:AppVeyor} -eq "True")
{
	$MSBuild = "MSBuild.exe"
}
ElseIf (${VisualStudioVersion} -eq "2008")
{
	$MSBuild = "C:\Windows\Microsoft.NET\Framework\v3.5\MSBuild.exe"
}
ElseIf ((${VisualStudioVersion} -eq "2010") -Or (${VisualStudioVersion} -eq "2012"))
{
	$MSBuild = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
}
ElseIf (${VisualStudioVersion} -eq "2013")
{
	$MSBuild = "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe"
}
ElseIf (${VisualStudioVersion} -eq "2015")
{
	$MSBuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
}
ElseIf (${VisualStudioVersion} -eq "2017")
{
	$Results = Get-ChildItem -Path "C:\Program Files\Microsoft Visual Studio\${VisualStudioVersion}\*\MSBuild\15.0\Bin\MSBuild.exe" -Recurse -ErrorAction SilentlyContinue -Force

	If ($Results.Count -eq 0)
	{
		$Results = Get-ChildItem -Path "C:\Program Files (x86)\Microsoft Visual Studio\${VisualStudioVersion}\*\MSBuild\15.0\Bin\MSBuild.exe" -Recurse -ErrorAction SilentlyContinue -Force
	}
	If ($Results.Count -gt 0)
	{
		$MSBuild = $Results[0].FullName
	}
}
ElseIf (${VisualStudioVersion} -eq "2019" -Or ${VisualStudioVersion} -eq "2022")
{
	$Results = Get-ChildItem -Path "C:\Program Files\Microsoft Visual Studio\${VisualStudioVersion}\*\MSBuild\Current\Bin\MSBuild.exe" -Recurse -ErrorAction SilentlyContinue -Force

	If ($Results.Count -eq 0)
	{
		$Results = Get-ChildItem -Path "C:\Program Files (x86)\Microsoft Visual Studio\${VisualStudioVersion}\*\MSBuild\Current\Bin\MSBuild.exe" -Recurse -ErrorAction SilentlyContinue -Force
	}
	If ($Results.Count -gt 0)
	{
		$MSBuild = $Results[0].FullName
	}
}
If (-Not ${MSBuild})
{
	Write-Host "Unable to determine path to msbuild.exe" -foreground Red

	Exit ${ExitFailure}
}
ElseIf (-Not (Test-Path ${MSBuild}))
{
	Write-Host "Missing msbuild.exe: ${MSBuild}" -foreground Red

	Exit ${ExitFailure}
}


$PlatformToolset = ""

If (-Not ${PlatformToolset})
{
	If (${VisualStudioVersion} -eq "2015")
	{
		$PlatformToolset = "v140"
	}
	ElseIf (${VisualStudioVersion} -eq "2017")
	{
		$PlatformToolset = "v141"
	}
	ElseIf (${VisualStudioVersion} -eq "2019")
	{
		$PlatformToolset = "v142"
	}
	ElseIf (${VisualStudioVersion} -eq "2022")
	{
		$PlatformToolset = "v143"
	}
	Write-Host "PlatformToolset not set defauting to: ${PlatformToolset}"
}
$MSBuildOptions = "/verbosity:quiet /target:Build /property:Configuration=${Configuration},Platform=${Platform}"

If ($UseLegacyVersion)
{
	$DokanPath = "../dokan"
	$ProjectFile = "msvscpp\dokan.sln"
}
Else
{
	$DokanPath = "../dokany"
	$ProjectFile = "dokan\dokan.vcxproj"
}

Push-Location ${DokanPath}

Try
{
	Write-Host "${MSBuild} ${MSBuildOptions} ${ProjectFile}"

	Invoke-Expression -Command "& '${MSBuild}' ${MSBuildOptions} ${ProjectFile}"
}
Finally
{
	Pop-Location
}

