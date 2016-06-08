@echo off
setlocal EnableDelayedExpansion EnableExtensions

rem tweakable options
rem ideally most of these could be discovered automatically
set CORESETUP_CHANNEL=preview
set CORESETUP_HOST_VERSION=1.0.1-rc4-000380-00
set CORESETUP_SHARED_FRAMEWORK_VERSION=1.0.0-rc4-000380

set "TOP_DIR=%~dp0"
if %TOP_DIR:~-1%==\ set "TOP_DIR=%TOP_DIR:~0,-1%"
set "NUGET=%TOP_DIR%\nuget.exe"
set "POWERSHELL=powershell -noprofile -nologo"

set "PACKAGES_DIR=%TOP_DIR%\packages"
set "WWW_DIR=%TOP_DIR%\wwwroot"
SET "WWW_BINARIES_DIR=%WWW_DIR%\%CORESETUP_CHANNEL%\Binaries\%CORESETUP_SHARED_FRAMEWORK_VERSION%"
SET "WWW_SHARED_FRAMEWORK_DIR=%WWW_DIR%\%CORESETUP_CHANNEL%\Installers\%CORESETUP_SHARED_FRAMEWORK_VERSION%"
SET "WWW_HOST_DIR=%WWW_DIR%\%CORESETUP_CHANNEL%\Installers\%CORESETUP_HOST_VERSION%"

if not exist "%PACKAGES_DIR%" md "%PACKAGES_DIR%"
if not exist "%WWW_DIR%" md "%WWW_DIR%"
if not exist "%WWW_BINARIES_DIR%" md "%WWW_BINARIES_DIR%"
if not exist "%WWW_SHARED_FRAMEWORK_DIR%" md "%WWW_SHARED_FRAMEWORK_DIR%"
if not exist "%WWW_HOST_DIR%" md "%WWW_HOST_DIR%"

rem todo: start a web server
set CORECLR_VERSION_URL=http://localhost:56623/coreclr.txt
set COREFX_VERSION_URL=http://localhost:56623/corefx.txt
set CORESETUP_VERSION_URL=http://localhost:56623/core-setup.txt


rem -------- CoreCLR --------
pushd "%TOP_DIR%\coreclr"
build.cmd all x64 x86 release skiptests
if NOT errorlevel 0 (
  echo coreclr failed to build
  exit /b 1
)
popd

set "CORECLR_PACK_1=%TOP_DIR%\coreclr\bin\Product\Windows_NT.x64.Release\.nuget\pkg"
set "CORECLR_PACK_2=%TOP_DIR%\coreclr\bin\Product\Windows_NT.x86.Release\.nuget\pkg"
%NUGET% list -source "%CORECLR_PACK_1%" -source "%CORECLR_PACK_2%" -prerelease > "%WWW_DIR%\coreclr.txt"
%NUGET% init "%CORECLR_PACK_1%" "%PACKAGES_DIR%"
%NUGET% init "%CORECLR_PACK_2%" "%PACKAGES_DIR%"


rem -------- corefx --------
pushd "%TOP_DIR%\corefx"
build.cmd /p:ConfigurationGroup=Release /p:Platform=x64
if NOT errorlevel 0 (
  echo corefx x64 failed to build
  exit /b 1
)
build.cmd /p:ConfigurationGroup=Release /p:Platform=x86
if NOT errorlevel 0 (
  echo corefx x86 failed to build
  exit /b 1
)
popd

set "COREFX_PACK=%TOP_DIR%\corefx\bin\packages\Release"
%NUGET% list -source "%COREFX_PACK%" -prerelease > "%WWW_DIR%\corefx.txt"
%NUGET% init "%COREFX_PACK%" "%PACKAGES_DIR%"


rem -------- core-setup --------
pushd "%TOP_DIR%\core-setup"
rem todo: powershell -File build_projects\update-dependencies\update-dependencies.ps1 -t UpdateFiles
build.cmd -Configuration Release -Architecture x64
if NOT errorlevel 0 (
  echo core-setup x64 failed to build
  exit /b 1
)
build.cmd -Configuration Release -Architecture x86
if NOT errorlevel 0 (
  echo core-setup x86 failed to build
  exit /b 1
)
popd

set "CORESETUP_PACK_1=%TOP_DIR%\core-setup\artifacts\win10-x64\corehost"
set "CORESETUP_PACK_2=%TOP_DIR%\core-setup\artifacts\win10-x86\corehost"
%NUGET% list -source "%CORESETUP_PACK_1%" -source "%CORESETUP_PACK_2%" -prerelease > "%WWW_DIR%\core-setup.txt"
%NUGET% init "%CORESETUP_PACK_1%" "%PACKAGES_DIR%"
%NUGET% init "%CORESETUP_PACK_2%" "%PACKAGES_DIR%"

set "ALL_ARCH=x86 x64"
for %%i in (%ALL_ARCH%) do (
  xcopy "%TOP_DIR%\core-setup\artifacts\win10-%%i\packages\dotnet-*.zip" "%WWW_BINARIES_DIR%"
  xcopy "%TOP_DIR%\core-setup\artifacts\win10-%%i\packages\dotnet-*.exe" "%WWW_SHARED_FRAMEWORK_DIR%"
  xcopy "%TOP_DIR%\core-setup\artifacts\win10-%%i\packages\dotnet-sharedframework-*.msi" "%WWW_SHARED_FRAMEWORK_DIR%"
  xcopy "%TOP_DIR%\core-setup\artifacts\win10-%%i\packages\dotnet-host-*.msi" "%WWW_HOST_DIR%"
)


rem -------- cli --------
pushd "%TOP_DIR%\cli"
rem todo: powershell -File build_projects\update-dependencies\update-dependencies.ps1 -t UpdateFiles
build.cmd -Configuration Release
if NOT errorlevel 0 (
  echo cli failed to build
  exit /b 1
)
popd

set "CLI_PACK=C:\externsrc\dotnet\cli\artifacts\win10-x64\packages"
%NUGET% list -source "%CLI_PACK%" -prerelease > "%WWW_DIR%\cli.txt"
%NUGET% init "%CLI_PACK%" "%PACKAGES_DIR%"


echo DONE!
exit /b 0
