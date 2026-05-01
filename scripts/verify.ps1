# RoadSOS verification script (fast local gate)
#
# Runs the same high-signal checks CI expects from contributors:
# - dependency resolution
# - static analysis
# - unit/widget tests

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "Verifying RoadSOS..." -ForegroundColor Cyan

if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter is not installed. Please install Flutter before continuing."
    exit 1
}

Write-Host "flutter pub get" -ForegroundColor Yellow
flutter pub get

Write-Host "flutter analyze" -ForegroundColor Yellow
flutter analyze

Write-Host "flutter test" -ForegroundColor Yellow
flutter test

Write-Host "Verification complete." -ForegroundColor Green

