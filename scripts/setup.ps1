# RoadSOS Dev Setup Script

Write-Host "🚀 Initializing RoadSOS Development Environment..." -ForegroundColor Cyan

# 1. Check Flutter
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter is not installed. Please install Flutter before continuing."
    exit 1
}

# 2. Get Dependencies
Write-Host "📦 Fetching dependencies..." -ForegroundColor Yellow
flutter pub get

# 3. Handle .env
if (!(Test-Path .env)) {
    Write-Host "📄 Creating .env template..." -ForegroundColor Yellow
    @(
        "SUPABASE_URL=YOUR_URL",
        "SUPABASE_ANON_KEY=YOUR_KEY",
        "POWERSYNC_URL=YOUR_URL",
        "",
        "# Optional SOS SMS relay (India ERSS/iSafe-style partner HTTPS endpoint)",
        "INDIA_SOS_DISPATCH_URL=",
        "# iOS Twilio/backend — POST JSON { body, payload, latitude, longitude, destination }",
        "SMS_DISPATCH_URL=",
        "# Bearer for dispatch Edge Function if required",
        "SMS_DISPATCH_ANON_KEY="
    ) -join "`n" | Out-File .env
    Write-Host "⚠️ Created .env. Please fill in your Supabase/PowerSync credentials." -ForegroundColor Red
}

# 4. Run Analysis
Write-Host "🔍 Running initial analysis..." -ForegroundColor Yellow
flutter analyze

Write-Host "✅ Setup complete! You are ready to build RoadSOS." -ForegroundColor Green
