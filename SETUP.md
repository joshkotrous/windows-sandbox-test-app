# Setup and Running Instructions

This guide will help you install dependencies and run the Hello World application.

## Prerequisites

- **Windows 10/11** or Windows Server 2019+
- **Administrator privileges** (required for installing dependencies)
- **Internet connection** (for downloading packages and dependencies)

## Quick Start

### Option 1: Automated Setup (Recommended)

If you're starting from scratch or in a fresh Windows environment, use the automated install script:

```powershell
# Run from the project root directory
powershell -ExecutionPolicy Bypass -File .\build-and-run.ps1 -InstallDependencies
```

This single command will:
1. ✅ Install Chocolatey package manager
2. ✅ Install Visual Studio Build Tools (with web development workload)
3. ✅ Install IIS Express
4. ✅ Download NuGet CLI
5. ✅ Restore NuGet packages
6. ✅ Build the solution
7. ✅ Start the application on `http://localhost:5000`

**Note:** This process can take 15-30 minutes depending on your internet speed, as it downloads and installs Visual Studio Build Tools (~4-6GB).

---

### Option 2: Manual Setup (If Dependencies Already Installed)

If you already have Visual Studio Build Tools and IIS Express installed:

```powershell
# Run from the project root directory
powershell -ExecutionPolicy Bypass -File .\build-and-run.ps1
```

This will:
1. ✅ Restore NuGet packages
2. ✅ Build the solution
3. ✅ Start the application on `http://localhost:5000`

---

## Manual Installation Steps

If you prefer to install dependencies manually:

### Step 1: Install Chocolatey

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### Step 2: Install Visual Studio Build Tools

```powershell
choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.WebBuildTools --add Microsoft.VisualStudio.Workload.MSBuildTools"
```

### Step 3: Install IIS Express

```powershell
choco install iisexpress -y
```

### Step 4: Install .NET Framework 4.8 Developer Pack

```powershell
choco install netfx-4.8-devpack -y
```

### Step 5: Refresh Environment Variables

Close and reopen your PowerShell window, or run:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
```

---

## Starting the Application

### Using the Build Script

The `build-and-run.ps1` script handles everything:

```powershell
# From the project root directory
powershell -ExecutionPolicy Bypass -File .\build-and-run.ps1
```

### Manual Start (After Build)

If you've already built the application:

```powershell
# Navigate to project root
cd C:\path\to\windows-sandbox-test-app

# Start IIS Express
$iisExpress = "${env:ProgramFiles}\IIS Express\iisexpress.exe"
$webRoot = "C:\path\to\windows-sandbox-test-app\HelloWorldApp"
& $iisExpress /path:"$webRoot" /port:5000
```

---

## Accessing the Application

Once the application is running, you'll see output like:

```
========================================
  Application is running!
========================================

  Frontend: http://localhost:5000/
  API:      http://localhost:5000/api/hello
```

### Available Endpoints

| Endpoint | URL | Description |
|----------|-----|-------------|
| **Frontend** | `http://localhost:5000/` | Hello World web page |
| **API** | `http://localhost:5000/api/hello` | Returns JSON: `{"message": "Hello World!", "timestamp": "..."}` |
| **API (with name)** | `http://localhost:5000/api/hello/YourName` | Returns personalized greeting |

### Opening in Browser

1. Open your web browser (Chrome, Edge, Firefox, etc.)
2. Navigate to: **http://localhost:5000/**
3. You should see the "Hello World!" page

### Testing the API

You can test the API using PowerShell:

```powershell
# Test the API endpoint
Invoke-RestMethod -Uri "http://localhost:5000/api/hello"

# Test with a name parameter
Invoke-RestMethod -Uri "http://localhost:5000/api/hello/John"
```

Or use a tool like:
- **Postman**
- **curl**: `curl http://localhost:5000/api/hello`
- **Browser**: Navigate to `http://localhost:5000/api/hello`

---

## Stopping the Application

To stop IIS Express:

1. **Press `Ctrl+C`** in the PowerShell window where IIS Express is running, OR
2. **Close the PowerShell window**, OR
3. **Kill the process**:
   ```powershell
   Get-Process -Name iisexpress | Stop-Process -Force
   ```

---

## Troubleshooting

### Issue: "MSBuild not found"

**Solution:** Install Visual Studio Build Tools:
```powershell
choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.WebBuildTools"
```

### Issue: "IIS Express not found"

**Solution:** Install IIS Express:
```powershell
choco install iisexpress -y
```

### Issue: "Port 5000 is already in use"

**Solution:** Either:
- Stop the process using port 5000:
  ```powershell
  netstat -ano | findstr :5000
  # Note the PID, then:
  taskkill /PID <PID> /F
  ```
- Or modify the script to use a different port

### Issue: "Could not load file or assembly" errors

**Solution:** Ensure all NuGet packages are restored and copied to the bin folder:
```powershell
.\nuget.exe restore HelloWorldApp.sln
# Then rebuild
```

### Issue: Build fails with ".NET Framework 4.8 not found"

**Solution:** Install the .NET Framework 4.8 Developer Pack:
```powershell
choco install netfx-4.8-devpack -y
```

### Issue: Script execution is disabled

**Solution:** Run PowerShell with execution policy bypass:
```powershell
powershell -ExecutionPolicy Bypass -File .\build-and-run.ps1
```

---

## File Structure

After setup, your project should have:

```
windows-sandbox-test-app/
├── HelloWorldApp/          # Main application
│   ├── bin/                # Compiled DLLs (generated)
│   ├── Controllers/        # MVC and API controllers
│   ├── Views/              # Razor views
│   └── Web.config          # Application configuration
├── packages/               # NuGet packages (restored, not committed)
├── build-and-run.ps1      # Build and run script
├── HelloWorldApp.sln       # Visual Studio solution
└── SETUP.md               # This file
```

---

## Next Steps

- ✅ Application is running at `http://localhost:5000/`
- ✅ API is available at `http://localhost:5000/api/hello`
- ✅ Ready for development!

For more details, see the main [README.md](README.md) file.
