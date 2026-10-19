@echo off
setlocal

rem Run this when internet is off. It skips Flutter's GitHub version check
rem and skips pub.dev package checks. Uses HTML renderer for offline support.
flutter --no-version-check run -d chrome --no-pub --web-renderer html
