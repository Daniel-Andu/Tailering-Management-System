@echo off
REM Git Sync Workflow for Deploying Branch
REM This script stages, commits, and pushes all changes to deploying branch

echo ========================================
echo Git Sync Workflow - Deploying Branch
echo ========================================
echo.

cd /d "%~dp0"

echo Step 1: Checking current git status...
git status
echo.

pause

echo Step 2: Staging all changes...
git add .
echo.

echo Step 3: Showing what will be committed...
git status
echo.

pause

echo Step 4: Committing with comprehensive message...
git commit -m "feat: add dark theme, profile screen, polish navigation, and A8 documentation" -m "- Implement ThemeProvider with Light/Dark/System mode support" -m "- Add Profile screen replacing More tab" -m "- Create App Drawer for hidden navigation items" -m "- Polish authentication screens with dark theme support" -m "- Refactor bottom navigation (shorten Measurements to Measure)" -m "- Add comprehensive A8 architecture documentation with UML diagrams" -m "- Remove debug screen functionality" -m "- Add OTP verification screen with SendLib integration" -m "- Create Startupname_A8.md and supporting documentation files"
echo.

echo Step 5: Pushing to remote deploying branch...
git push origin deploying
echo.

echo ========================================
echo SUCCESS! Changes pushed to origin/deploying
echo ========================================
echo.
echo Next steps:
echo 1. Go to: https://github.com/YOUR_USERNAME/Tailering-Management-System
echo 2. You should see "Compare & pull request" button
echo 3. Click it to create Pull Request from deploying to main
echo 4. Add description and submit PR
echo.

pause
