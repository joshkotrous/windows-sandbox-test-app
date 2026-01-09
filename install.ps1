# Install script - Restores packages and builds the solution
$ErrorActionPreference = "Stop"

# Find NuGet
$nuget = if (Test-Path ".\nuget.exe") { ".\nuget.exe" } else { "nuget" }

# Find MSBuild (try common locations)
$msbuild = $null
$paths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\*\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\*\MSBuild\Current\Bin\MSBuild.exe",
    "${env:SystemRoot}\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
)

foreach ($path in $paths) {
    $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $msbuild = $found.FullName
        break
    }
}

if (-not $msbuild) {
    Write-Error "MSBuild not found! Please install Visual Studio Build Tools."
    exit 1
}

# Download NuGet if needed
if (-not (Test-Path ".\nuget.exe") -and -not (Get-Command $nuget -ErrorAction SilentlyContinue)) {
    Write-Host "Downloading NuGet..."
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile ".\nuget.exe"
    $nuget = ".\nuget.exe"
}

# Restore packages
Write-Host "Restoring NuGet packages..."
& $nuget restore HelloWorldApp.sln
if ($LASTEXITCODE -ne 0) {
    Write-Error "NuGet restore failed!"
    exit 1
}

# Build solution
Write-Host "Building solution..."
& $msbuild HelloWorldApp.sln /p:Configuration=Release /p:Platform="Any CPU" /t:Build /v:minimal
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    exit 1
}

# Copy required DLLs to bin folder
Write-Host "Copying required DLLs to bin folder..."
$binPath = "HelloWorldApp\bin"
if (-not (Test-Path $binPath)) {
    New-Item -ItemType Directory -Path $binPath -Force | Out-Null
}

$packagesPath = "packages"
if (Test-Path $packagesPath) {
    Copy-Item "$packagesPath\Microsoft.AspNet.Razor.3.2.9\lib\net45\*.dll" -Destination $binPath -Force -ErrorAction SilentlyContinue
    Copy-Item "$packagesPath\Microsoft.AspNet.WebPages.3.2.9\lib\net45\*.dll" -Destination $binPath -Force -ErrorAction SilentlyContinue
    Copy-Item "$packagesPath\Microsoft.AspNet.Mvc.5.2.9\lib\net45\*.dll" -Destination $binPath -Force -ErrorAction SilentlyContinue
    Copy-Item "$packagesPath\Microsoft.AspNet.WebApi.Core.5.2.9\lib\net45\*.dll" -Destination $binPath -Force -ErrorAction SilentlyContinue
    Copy-Item "$packagesPath\Microsoft.AspNet.WebApi.WebHost.5.2.9\lib\net45\*.dll" -Destination $binPath -Force -ErrorAction SilentlyContinue
    Copy-Item "$packagesPath\Microsoft.AspNet.WebApi.Client.5.2.9\lib\net45\*.dll" -Destination $binPath -Force -ErrorAction SilentlyContinue
    Copy-Item "$packagesPath\Newtonsoft.Json.13.0.3\lib\net45\*.dll" -Destination $binPath -Force -ErrorAction SilentlyContinue
    Copy-Item "$packagesPath\Microsoft.Web.Infrastructure.2.0.0\lib\net40\*.dll" -Destination $binPath -Force -ErrorAction SilentlyContinue
}

Write-Host "Install completed successfully!" -ForegroundColor Green
