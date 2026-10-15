@echo off
setlocal

rem Use this if diagnose_release_build.bat still only shows the generic footer.
cd android
gradlew.bat assembleRelease --stacktrace --info
