Write-Host "🐧 Silly Enterprises™ Windows Installer"
Write-Host "---"
if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Write-Warning "WSL is not installed."
    Write-Host "Please install WSL and Ubuntu before running this script."
    Write-Host "More info: https://aka.ms/wsl"
    exit 1
}
Write-Host "Launching install script in WSL..."
wsl bash -c "curl -fsSL https://install.silly.enterprises | bash"