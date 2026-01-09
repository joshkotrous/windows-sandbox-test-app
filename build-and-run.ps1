<#
.SYNOPSIS
    Builds and runs the Hello World .NET Framework application programmatically.

.DESCRIPTION
    This script will:
    1. Install required build tools if missing (via Chocolatey)
    2. Restore NuGet packages
    3. Build the solution
    4. Run the application using IIS Express

.PARAMETER InstallDependencies
    If specified, installs Visual Studio Build Tools and IIS Express via Chocolatey

.EXAMPLE
    .\build-and-run.ps1
    .\build-and-run.ps1 -InstallDependencies
#>

param(
    [switch]$InstallDependencies
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$solutionPath = Join-Path $scriptDir "HelloWorldApp.sln"
$projectPath = Join-Path $scriptDir "HelloWorldApp\HelloWorldApp.csproj"
$webRoot = Join-Path $scriptDir "HelloWorldApp"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Hello World .NET Framework Builder   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Function to find MSBuild
function Find-MSBuild {
    # Try VS 2022
    $vs2022 = "${env:ProgramFiles}\Microsoft Visual Studio\2022\*\MSBuild\Current\Bin\MSBuild.exe"
    $found = Get-ChildItem -Path $vs2022 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { return $found.FullName }

    # Try VS 2019
    $vs2019 = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\*\MSBuild\Current\Bin\MSBuild.exe"
    $found = Get-ChildItem -Path $vs2019 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { return $found.FullName }

    # Try Build Tools
    $buildTools = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    if (Test-Path $buildTools) { return $buildTools }

    $buildTools2019 = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    if (Test-Path $buildTools2019) { return $buildTools2019 }

    # Try .NET Framework MSBuild
    $frameworkMSBuild = "${env:SystemRoot}\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
    if (Test-Path $frameworkMSBuild) { return $frameworkMSBuild }

    return $null
}

# Function to find NuGet
function Find-NuGet {
    if (Test-Command "nuget") { return "nuget" }
    
    $localNuget = Join-Path $scriptDir "nuget.exe"
    if (Test-Path $localNuget) { return $localNuget }
    
    return $null
}

# Function to find IIS Express
function Find-IISExpress {
    $iisExpress = "${env:ProgramFiles}\IIS Express\iisexpress.exe"
    if (Test-Path $iisExpress) { return $iisExpress }
    
    $iisExpress86 = "${env:ProgramFiles(x86)}\IIS Express\iisexpress.exe"
    if (Test-Path $iisExpress86) { return $iisExpress86 }
    
    return $null
}

# Install dependencies if requested
if ($InstallDependencies) {
    Write-Host "[1/5] Installing dependencies..." -ForegroundColor Yellow
    
    # Check for Chocolatey
    if (-not (Test-Command "choco")) {
        Write-Host "Installing Chocolatey..." -ForegroundColor Gray
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }
    
    # Install Build Tools
    Write-Host "Installing Visual Studio Build Tools..." -ForegroundColor Gray
    choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.WebBuildTools --add Microsoft.VisualStudio.Workload.MSBuildTools"
    
    # Install IIS Express
    Write-Host "Installing IIS Express..." -ForegroundColor Gray
    choco install iisexpress -y
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Step 1: Find or download NuGet
Write-Host "[1/5] Locating NuGet..." -ForegroundColor Yellow
$nuget = Find-NuGet
if (-not $nuget) {
    Write-Host "Downloading NuGet..." -ForegroundColor Gray
    $nugetPath = Join-Path $scriptDir "nuget.exe"
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nugetPath
    $nuget = $nugetPath
}
Write-Host "  Found: $nuget" -ForegroundColor Green

# Step 2: Find MSBuild
Write-Host "[2/5] Locating MSBuild..." -ForegroundColor Yellow
$msbuild = Find-MSBuild
if (-not $msbuild) {
    Write-Error "MSBuild not found! Run with -InstallDependencies or install Visual Studio Build Tools manually."
    exit 1
}
Write-Host "  Found: $msbuild" -ForegroundColor Green

# Step 3: Restore NuGet packages
Write-Host "[3/5] Restoring NuGet packages..." -ForegroundColor Yellow
& $nuget restore $solutionPath
if ($LASTEXITCODE -ne 0) {
    Write-Error "NuGet restore failed!"
    exit 1
}
Write-Host "  Packages restored successfully" -ForegroundColor Green

# Step 4: Build the solution
Write-Host "[4/5] Building solution..." -ForegroundColor Yellow
& $msbuild $solutionPath /p:Configuration=Release /p:Platform="Any CPU" /t:Build /v:minimal
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    exit 1
}
Write-Host "  Build completed successfully" -ForegroundColor Green

# Step 5: Run with IIS Express
Write-Host "[5/5] Starting IIS Express..." -ForegroundColor Yellow
$iisExpress = Find-IISExpress
if (-not $iisExpress) {
    Write-Error "IIS Express not found! Run with -InstallDependencies or install IIS Express manually."
    exit 1
}

$port = 5000
$configPath = Join-Path $scriptDir "iisexpress.config"

# Generate IIS Express configuration
$iisConfig = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.applicationHost>
        <sites>
            <site name="HelloWorldApp" id="1">
                <application path="/" applicationPool="Clr4IntegratedAppPool">
                    <virtualDirectory path="/" physicalPath="$webRoot" />
                </application>
                <bindings>
                    <binding protocol="http" bindingInformation="*:${port}:localhost" />
                </bindings>
            </site>
        </sites>
        <applicationPools>
            <add name="Clr4IntegratedAppPool" managedRuntimeVersion="v4.0" managedPipelineMode="Integrated" CLRConfigFile="" passAnonymousToken="true" />
        </applicationPools>
    </system.applicationHost>
</configuration>
"@

$iisConfig | Out-File -FilePath $configPath -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Application starting on port $port   " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Web Page: http://localhost:$port/" -ForegroundColor White
Write-Host "  API:      http://localhost:$port/api/hello" -ForegroundColor White
Write-Host ""
Write-Host "  Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

# Start IIS Express
& $iisExpress /config:$configPath /site:HelloWorldApp
