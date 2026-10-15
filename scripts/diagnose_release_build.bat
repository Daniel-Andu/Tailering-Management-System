@echo off
setlocal

rem Use this when release build fails. Copy the first error above the final
rem "BUILD FAILED" footer.
flutter --no-version-check build apk --release --no-pub --verbose --no-tree-shake-icons
