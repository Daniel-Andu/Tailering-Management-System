@echo off
setlocal

rem Fast offline release build. Run flutter pub get once while internet is on,
rem then use this script for normal release builds.
flutter --no-version-check build apk --release --no-pub --split-per-abi --no-tree-shake-icons
