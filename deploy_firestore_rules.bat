@echo off
echo ========================================
echo Deploying Firestore Security Rules
echo ========================================
echo.
echo NOTE: Make sure you have Firebase CLI installed
echo If not, run: npm install -g firebase-tools
echo.
echo You'll need to login first if you haven't:
echo   firebase login
echo.
echo ========================================
echo.

firebase deploy --only firestore:rules

echo.
echo ========================================
echo Deployment complete!
echo ========================================
pause
