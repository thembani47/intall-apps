# =====================================================================
# Data Science Practitioner (SAQA 118708) - EISA Software Setup
# One-shot installer using winget (built into Windows 10/11)
# Run this in PowerShell AS ADMINISTRATOR:
#   1. Press Win, type "PowerShell", right-click > Run as administrator
#   2. cd to the folder containing this script
#   3. Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   4. .\EISA_118708_install_all.ps1
# =====================================================================

Write-Host "Checking winget is available..." -ForegroundColor Cyan
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store first, then re-run." -ForegroundColor Red
    exit 1
}

function Install-App($id, $name) {
    Write-Host "`nInstalling $name ..." -ForegroundColor Yellow
    winget install -e --id $id --accept-source-agreements --accept-package-agreements
}

# ---- CONFIRMED (required by MICT SETA / RFQ) ----
Install-App "Anaconda.Anaconda3"         "Anaconda (Python + Jupyter + core libraries)"
Install-App "Microsoft.VisualStudioCode" "Visual Studio Code"
Install-App "Oracle.MySQL"               "MySQL Community Server"   # swap for PostgreSQL.PostgreSQL or MariaDB.MariaDB if your provider uses those

# ---- RECOMMENDED (industry practice / provider discretion) ----
Install-App "Microsoft.PowerBI"          "Power BI Desktop"
Install-App "RProject.R"                 "R"
Install-App "RStudio.RStudio"            "RStudio Desktop"
Install-App "7zip.7zip"                  "7-Zip"

# ---- DEVELOPMENT TOOLS ----
Install-App "Python.Python.3.12"             "Python 3.12 (standalone)"
Install-App "EclipseAdoptium.Temurin.21.JDK" "Java JDK 21 (Eclipse Temurin)"
Install-App "JetBrains.IntelliJIDEA.Community" "IntelliJ IDEA Community Edition"
Install-App "Docker.DockerDesktop"           "Docker Desktop"

# ---- JUnit (no winget package: it is a library, so download the console launcher jar) ----
# IntelliJ also bundles JUnit support, and Maven/Gradle projects can pull it in as a dependency.
$junitVersion = "1.10.2"
$junitDir     = "C:\junit"
$junitJar     = Join-Path $junitDir "junit-platform-console-standalone-$junitVersion.jar"
$junitUrl     = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/$junitVersion/junit-platform-console-standalone-$junitVersion.jar"

Write-Host "`nDownloading JUnit $junitVersion ..." -ForegroundColor Yellow
try {
    New-Item -ItemType Directory -Force -Path $junitDir | Out-Null
    Invoke-WebRequest -Uri $junitUrl -OutFile $junitJar -UseBasicParsing
    Write-Host "JUnit saved to $junitJar" -ForegroundColor Green
} catch {
    Write-Host "JUnit download failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You can still use JUnit through IntelliJ or a Maven/Gradle dependency." -ForegroundColor Red
}

# ---- Refresh PATH so newly installed Python/Anaconda are visible in this session ----
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# ---- Python libraries not already bundled with Anaconda ----
Write-Host "`nInstalling additional Python packages via pip..." -ForegroundColor Yellow
if (Get-Command pip -ErrorAction SilentlyContinue) {
    pip install --upgrade sqlalchemy openpyxl xgboost statsmodels
} else {
    Write-Host "pip not found in this session. Open a NEW terminal and run:" -ForegroundColor Red
    Write-Host "  pip install --upgrade sqlalchemy openpyxl xgboost statsmodels"
}

Write-Host "`n=====================================================================" -ForegroundColor Green
Write-Host "Automated installs complete. STILL TO DO MANUALLY:" -ForegroundColor Green
Write-Host " - Microsoft 365 (Word/Excel/PowerPoint): install & activate via your"
Write-Host "   organisation's Office portal/licence - not scriptable via winget"
Write-Host "   without an existing subscription sign-in."
Write-Host " - Docker Desktop: restart Windows, launch Docker Desktop once, accept"
Write-Host "   the licence and let it enable WSL 2 / virtualisation if prompted."
Write-Host " - Confirm with your accredited provider which DB (MySQL/Postgres/"
Write-Host "   MariaDB) and which visual analytics tool (Power BI/Tableau/Python)"
Write-Host "   will actually be used in the EISA."
Write-Host " - Verify installs (in a NEW terminal): python --version | java -version |"
Write-Host "   docker --version | conda list scipy scikit-learn | jupyter --version"
Write-Host "=====================================================================" -ForegroundColor Green
