# Verification script for dialog overflow fixes

Write-Host "`n=== Verifying Dialog Overflow Fixes ===" -ForegroundColor Cyan

# Check 1: Look for isExpanded in order board screen
Write-Host "`n1. Checking for isExpanded in Order Dialog..." -ForegroundColor Yellow
$isExpandedCount = (Select-String -Path "lib\features\orders\screens\order_board_screen.dart" -Pattern "isExpanded: true").Count
Write-Host "   Found $isExpandedCount instances of 'isExpanded: true'" -ForegroundColor $(if ($isExpandedCount -ge 4) { "Green" } else { "Red" })

if ($isExpandedCount -ge 4) {
    Write-Host "   ✅ All dropdowns have isExpanded!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Missing isExpanded on some dropdowns!" -ForegroundColor Red
}

# Check 2: Look for debug output in order board
Write-Host "`n2. Checking for debug output in Order Dialog..." -ForegroundColor Yellow
$debugOrder = Select-String -Path "lib\features\orders\screens\order_board_screen.dart" -Pattern "NEW ORDER DIALOG"
if ($debugOrder) {
    Write-Host "   ✅ Debug output found in order dialog!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Debug output NOT found!" -ForegroundColor Red
}

# Check 3: Look for debug output in measurements screen
Write-Host "`n3. Checking for debug output in Measurements Dialog..." -ForegroundColor Yellow
$debugMeasure = Select-String -Path "lib\features\measurements\screens\measurements_screen.dart" -Pattern "ADD CUSTOM FIELD DIALOG"
if ($debugMeasure) {
    Write-Host "   ✅ Debug output found in measurements dialog!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Debug output NOT found!" -ForegroundColor Red
}

# Check 4: Verify fixed SizedBox structure
Write-Host "`n4. Checking dialog structure..." -ForegroundColor Yellow
$sizedBoxOrder = Select-String -Path "lib\features\orders\screens\order_board_screen.dart" -Pattern "SizedBox\(\s*width: 600"
$sizedBoxMeasure = Select-String -Path "lib\features\measurements\screens\measurements_screen.dart" -Pattern "SizedBox\(\s*width: 500"

if ($sizedBoxOrder -and $sizedBoxMeasure) {
    Write-Host "   ✅ Both dialogs use fixed SizedBox!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Fixed SizedBox structure not found!" -ForegroundColor Red
}

Write-Host "`n=== Verification Complete ===" -ForegroundColor Cyan
Write-Host "`n📋 Summary:" -ForegroundColor Cyan
Write-Host "   - DropdownButtonFormField fixes: $(if ($isExpandedCount -ge 4) { '✅' } else { '❌' })" -ForegroundColor White
Write-Host "   - Debug output (Order): $(if ($debugOrder) { '✅' } else { '❌' })" -ForegroundColor White
Write-Host "   - Debug output (Measurements): $(if ($debugMeasure) { '✅' } else { '❌' })" -ForegroundColor White
Write-Host "   - Dialog structure: $(if ($sizedBoxOrder -and $sizedBoxMeasure) { '✅' } else { '❌' })" -ForegroundColor White

Write-Host ""
Write-Host "IMPORTANT: You MUST perform a HOT RESTART (not hot reload)!" -ForegroundColor Yellow
Write-Host "Press Ctrl+Shift+F5 in IDE or restart flutter run" -ForegroundColor Yellow
Write-Host ""

