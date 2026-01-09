# Hello World - Legacy .NET Framework Application

A simple ASP.NET MVC application targeting .NET Framework 4.8 with Web API support.

## Features

- **Web Page**: A Hello World homepage at `/`
- **API Endpoint**: RESTful API at `/api/hello`

## Requirements

- Windows 10/11 or Windows Server
- .NET Framework 4.8
- Visual Studio 2019/2022 or MSBuild
- IIS Express (for local development) or IIS (for deployment)

## Project Structure

```
HelloWorldApp/
├── App_Start/
│   ├── RouteConfig.cs       # MVC routing configuration
│   └── WebApiConfig.cs      # Web API configuration
├── Controllers/
│   ├── HomeController.cs    # MVC controller for web pages
│   └── Api/
│       └── HelloApiController.cs  # Web API controller
├── Views/
│   ├── Home/
│   │   └── Index.cshtml     # Homepage view
│   ├── Shared/
│   │   └── _Layout.cshtml   # Layout template
│   └── Web.config           # Views configuration
├── Properties/
│   └── AssemblyInfo.cs
├── Global.asax              # Application entry point
├── Global.asax.cs
├── Web.config               # Main configuration
├── packages.config          # NuGet packages
└── HelloWorldApp.csproj     # Project file
```

## Building the Project

### Using Visual Studio

1. Open `HelloWorldApp.sln` in Visual Studio
2. Right-click on the solution and select "Restore NuGet Packages"
3. Build the solution (Ctrl+Shift+B)
4. Press F5 to run with IIS Express

### Using Command Line

```powershell
# Restore NuGet packages
nuget restore HelloWorldApp.sln

# Build the solution
msbuild HelloWorldApp.sln /p:Configuration=Release
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/hello` | Returns a hello world JSON response |
| GET | `/api/hello/{name}` | Returns a personalized greeting |

### Example Responses

**GET /api/hello**
```json
{
  "message": "Hello World!",
  "timestamp": "2026-01-09T12:00:00Z"
}
```

**GET /api/hello/John**
```json
{
  "message": "Hello, John!",
  "timestamp": "2026-01-09T12:00:00Z"
}
```

## Programmatic Build & Run (For Agents)

This section provides step-by-step instructions for AI agents or automation scripts to programmatically set up and run the development environment.

### Quick Start (Single Command)

If running inside Windows Sandbox or a fresh Windows environment with internet access:

```powershell
# From the project root directory, run:
powershell -ExecutionPolicy Bypass -File .\build-and-run.ps1 -InstallDependencies
```

This single command will:
1. Install Chocolatey package manager
2. Install Visual Studio Build Tools with web workload
3. Install IIS Express
4. Download NuGet CLI
5. Restore NuGet packages
6. Build the solution
7. Start the application on `http://localhost:5000`

### Step-by-Step Manual Setup

If you need more control, execute these commands in order:

```powershell
# Step 1: Set execution policy (required for scripts)
Set-ExecutionPolicy Bypass -Scope Process -Force

# Step 2: Install Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Step 3: Install .NET Framework 4.8 Developer Pack
choco install netfx-4.8-devpack -y

# Step 4: Install Visual Studio Build Tools
choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.WebBuildTools --add Microsoft.VisualStudio.Workload.MSBuildTools"

# Step 5: Install IIS Express
choco install iisexpress -y

# Step 6: Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Step 7: Download NuGet (from project root)
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile ".\nuget.exe"

# Step 8: Restore packages
.\nuget.exe restore HelloWorldApp.sln

# Step 9: Build the solution
$msbuild = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
& $msbuild HelloWorldApp.sln /p:Configuration=Release /t:Build

# Step 10: Run with IIS Express
$iisExpress = "${env:ProgramFiles}\IIS Express\iisexpress.exe"
& $iisExpress /path:"$PWD\HelloWorldApp" /port:5000
```

### Expected Endpoints After Startup

| Endpoint | URL | Expected Response |
|----------|-----|-------------------|
| Web Page | `http://localhost:5000/` | HTML page with "Hello World!" |
| API | `http://localhost:5000/api/hello` | `{"message": "Hello World!", "timestamp": "..."}` |
| API (named) | `http://localhost:5000/api/hello/Agent` | `{"message": "Hello, Agent!", "timestamp": "..."}` |

### Verifying the Application is Running

```powershell
# Test the API endpoint
$response = Invoke-RestMethod -Uri "http://localhost:5000/api/hello" -Method Get
if ($response.message -eq "Hello World!") {
    Write-Host "SUCCESS: Application is running correctly"
} else {
    Write-Host "ERROR: Unexpected response"
}
```

### Environment Requirements

| Requirement | Details |
|-------------|---------|
| OS | Windows 10/11 or Windows Server 2019+ |
| RAM | Minimum 4GB (8GB recommended for build tools) |
| Disk | ~10GB free space (for build tools and packages) |
| Network | Internet access required for package downloads |
| Permissions | Administrator privileges required for Chocolatey installs |

### Troubleshooting

| Issue | Solution |
|-------|----------|
| MSBuild not found | Ensure Build Tools installed: `choco install visualstudio2022buildtools -y` |
| NuGet restore fails | Check internet connectivity; try `.\nuget.exe restore -verbosity detailed` |
| IIS Express won't start | Check if port 5000 is in use: `netstat -ano \| findstr :5000` |
| Build errors | Ensure .NET 4.8 Dev Pack installed: `choco install netfx-4.8-devpack -y` |

---

## Programmatic Build Options (Alternative Methods)

### Option 1: Docker (Windows Containers)

> ⚠️ **Requires Windows with Docker Desktop in Windows Containers mode**

```powershell
# Switch Docker to Windows containers (right-click Docker icon → Switch to Windows containers)

# Build and run
docker-compose up --build

# Or manually:
docker build -t helloworld-legacy .
docker run -d -p 8080:80 helloworld-legacy
```

Access at: `http://localhost:8080`

**Note:** Windows container images are large (~5-8GB). First build takes time.

### Option 2: PowerShell Script

```powershell
# Basic build and run (requires Visual Studio Build Tools pre-installed)
.\build-and-run.ps1

# Full setup - installs all dependencies via Chocolatey
.\build-and-run.ps1 -InstallDependencies
```

### Option 3: Windows Sandbox

For a completely isolated test environment:

1. Edit `HelloWorldSandbox.wsb` and update `<HostFolder>` to your actual path
2. Double-click `HelloWorldSandbox.wsb` to launch
3. The sandbox will automatically install dependencies and run the app

## Deployment

### IIS Deployment

1. Publish the application from Visual Studio or use MSBuild
2. Create a new IIS website or application
3. Point the physical path to the published folder
4. Ensure the application pool is set to .NET Framework 4.8

### Windows Sandbox Testing

This application is designed for testing in Windows Sandbox. Copy the entire solution folder to the sandbox and build/run it there.
