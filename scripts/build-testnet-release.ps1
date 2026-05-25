# Release builds: production API + Sui testnet (APK + optional web).
param(
  [ValidateSet("apk", "web", "both")]
  [string]$Target = "apk"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot/..

$api = "https://mrm-rental-manager-backend.vercel.app"
$defines = @(
  "--dart-define=API_BASE_URL=$api",
  "--dart-define=SUI_NETWORK=testnet",
  "--dart-define=SUI_RPC_URL=https://fullnode.testnet.sui.io:443",
  "--dart-define=SUI_EXPLORER_BASE=https://suiscan.xyz/testnet"
)

if ($Target -eq "apk" -or $Target -eq "both") {
  Write-Host "Building Android APK (testnet)..."
  flutter build apk --release @defines
  Write-Host "APK: build/app/outputs/flutter-apk/app-release.apk"
}

if ($Target -eq "web" -or $Target -eq "both") {
  Write-Host "Building Flutter web (testnet)..."
  flutter build web --release @defines
  Write-Host "Web: build/web — deploy with: npx vercel deploy --prod"
}
