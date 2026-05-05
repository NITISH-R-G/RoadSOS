# RoadSOS verification script (fast local gate)
#
# Runs the same high-signal checks CI expects from contributors:
# - dependency resolution
# - static analysis
# - unit/widget tests

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "Verifying RoadSOS..." -ForegroundColor Cyan

if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    $winFlutter = "$env:LOCALAPPDATA\Android\flutter\bin\flutter.bat"
    if (Test-Path $winFlutter) {
        Write-Host "Flutter found at Android SDK path; add to PATH:" -ForegroundColor Yellow
        Write-Host "  $winFlutter" -ForegroundColor Gray
        Write-Host "Or run: `$env:Path = `"$(Split-Path $winFlutter -Parent);`" + `$env:Path" -ForegroundColor Gray
    }
    Write-Error @"
Flutter is not on PATH. Install: https://docs.flutter.dev/get-started/install/windows
Then reopen the terminal and run this script again from the repo root:
  .\scripts\verify.ps1
"@
    exit 1
}

Write-Host "flutter pub get" -ForegroundColor Yellow
flutter pub get

Write-Host "flutter analyze" -ForegroundColor Yellow
flutter analyze

Write-Host "flutter test" -ForegroundColor Yellow
flutter test

Write-Host "Verification complete." -ForegroundColor Green

