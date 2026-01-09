# Start script - Starts IIS Express with the application
$ErrorActionPreference = "Stop"

$webRoot = Resolve-Path "HelloWorldApp"
$port = 5000

# Find IIS Express
$iisExpress = "${env:ProgramFiles}\IIS Express\iisexpress.exe"
if (-not (Test-Path $iisExpress)) {
    $iisExpress = "${env:ProgramFiles(x86)}\IIS Express\iisexpress.exe"
}

if (-not (Test-Path $iisExpress)) {
    Write-Error "IIS Express not found! Please install IIS Express."
    exit 1
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Starting application on port $port   " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Frontend: http://localhost:$port/" -ForegroundColor Cyan
Write-Host "  API:      http://localhost:$port/api/hello" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

# Start IIS Express
& $iisExpress /path:"$webRoot" /port:$port
