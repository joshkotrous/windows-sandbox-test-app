<#
.SYNOPSIS
    Automated setup script for Windows Sandbox - installs dependencies, builds, and runs the app.
#>

$ErrorActionPreference = "Stop"
$projectPath = "C:\HelloWorldApp"

# Create a log file
Start-Transcript -Path "$projectPath\sandbox-log.txt" -Append

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows Sandbox Setup Script         " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Install Chocolatey
Write-Host "`n[1/6] Installing Chocolatey..." -ForegroundColor Yellow
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Install .NET Framework 4.8 Developer Pack
Write-Host "`n[2/6] Installing .NET Framework 4.8 Developer Pack..." -ForegroundColor Yellow
choco install netfx-4.8-devpack -y

# Install Visual Studio Build Tools with web workload
Write-Host "`n[3/6] Installing Visual Studio Build Tools..." -ForegroundColor Yellow
choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.WebBuildTools --add Microsoft.VisualStudio.Workload.MSBuildTools --includeRecommended"

# Install IIS Express
Write-Host "`n[4/6] Installing IIS Express..." -ForegroundColor Yellow
choco install iisexpress -y

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Download NuGet
Write-Host "`n[5/6] Downloading NuGet..." -ForegroundColor Yellow
$nugetPath = "$projectPath\nuget.exe"
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nugetPath

# Build the project
Write-Host "`n[6/6] Building the application..." -ForegroundColor Yellow
Set-Location $projectPath

# Restore packages
& $nugetPath restore HelloWorldApp.sln

# Find MSBuild
$msbuild = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe" -ErrorAction SilentlyContinue
if (-not $msbuild) {
    $msbuild = Get-ChildItem -Path "${env:ProgramFiles}\Microsoft Visual Studio\2022\*\MSBuild\Current\Bin\MSBuild.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
}
if (-not $msbuild) {
    $msbuild = "${env:SystemRoot}\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
}

# Build
& $msbuild HelloWorldApp.sln /p:Configuration=Release /t:Build

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Build Complete! Starting server...   " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Run the PowerShell build script
& powershell -ExecutionPolicy Bypass -File "$projectPath\build-and-run.ps1"

Stop-Transcript
