@echo off
title Hiddify Reset + Setup
net session >nul 2>&1 || (
  powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText('%~f0'); iex ($s.Substring($s.LastIndexOf('#PS_START')+9))"
echo.
pause
exit /b

#PS_START
$ErrorActionPreference = 'SilentlyContinue'
function Say($m){ Write-Host "==> $m" -ForegroundColor Cyan }

# 1) Find Hiddify.exe
$exe = @(
  "$env:ProgramFiles\Hiddify\Hiddify.exe",
  "${env:ProgramFiles(x86)}\Hiddify\Hiddify.exe",
  "$env:LOCALAPPDATA\Programs\Hiddify\Hiddify.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $exe) {
  $exe = (Get-ChildItem "$env:ProgramFiles","$env:LOCALAPPDATA","$env:USERPROFILE\Desktop","$env:USERPROFILE\Downloads" -Recurse -Filter Hiddify.exe -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
if (-not $exe) { Write-Host "Hiddify.exe not found. Install Hiddify first, then run this again." -ForegroundColor Red; return }
Say "Hiddify found: $exe"

# 2) Stop everything Hiddify / sing-box
Say "Stopping Hiddify..."
Get-Process Hiddify,HiddifyAdmin,HiddifyCore,HiddifyCoreEngine,HiddifyCli,sing-box -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Service | Where-Object { $_.Name -like '*hiddify*' } | Stop-Service -Force
Start-Sleep 3

# 3) Remove leftover TUN adapters (fixes "set ipv6 address: The object already exists")
Say "Removing leftover TUN adapters..."
Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -like '*sing-tun*' -or $_.FriendlyName -like '*hiddify*' } |
  ForEach-Object { pnputil /remove-device $_.InstanceId | Out-Null }

# 4) Full reset of Hiddify data (profiles, settings, cache)
Say "Resetting Hiddify data..."
foreach ($d in "$env:APPDATA\Hiddify", "$env:LOCALAPPDATA\Hiddify", "$env:APPDATA\app.hiddify.com", "$env:LOCALAPPDATA\app.hiddify.com") {
  if (Test-Path $d) { Remove-Item $d -Recurse -Force }
}

# 5) Write new settings
Say "Applying new settings..."
$dir = "$env:APPDATA\Hiddify\hiddify"
New-Item -ItemType Directory -Force $dir | Out-Null
$prefs = [ordered]@{
  'flutter.preferences_version'          = 5
  'flutter.intro_completed'              = $true
  'flutter.locale'                       = 'fa'
  'flutter.disable_experimental_feature_notice' = $true
  'flutter.disable_memory_limit'         = $true
  'flutter.service-mode'                 = 'vpn'
  'flutter.region'                       = 'ir'
  'flutter.direct-dns-address'           = 'udp://178.22.122.100'
  'flutter.remote-dns-address'           = 'udp://1.1.1.1'
  'flutter.ipv6-mode'                    = 'ipv4_only'
  'flutter.enable-dns-routing'           = $true
  'flutter.strict-route'                 = $true
  'flutter.bypass-lan'                   = $true
  'flutter.enable-fake-dns'              = $false
  'flutter.resolve-destination'          = $true
}
$json = $prefs | ConvertTo-Json -Compress
[IO.File]::WriteAllText("$dir\shared_preferences.json", $json, (New-Object Text.UTF8Encoding $false))

# 6) Desktop shortcut + start Hiddify (as normal user)
$lnk = (New-Object -ComObject WScript.Shell).CreateShortcut("$([Environment]::GetFolderPath('Desktop'))\Hiddify.lnk")
$lnk.TargetPath = $exe; $lnk.WorkingDirectory = Split-Path $exe; $lnk.Save()
Say "Starting Hiddify..."
Start-Process explorer.exe -ArgumentList "`"$exe`""

Write-Host ""
Write-Host "DONE. Add your profile in Hiddify and connect." -ForegroundColor Green
Write-Host "Settings: VPN(TUN) | Region=Iran | Direct DNS=Shecan | Remote DNS=1.1.1.1 | IPv4 only | Strict route" -ForegroundColor Green
