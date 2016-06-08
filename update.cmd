@echo off
setlocal EnableDelayedExpansion EnableExtensions

set "TOP_DIR=%~dp0"
if %TOP_DIR:~-1%==\ set "TOP_DIR=%TOP_DIR:~0,-1%"

set "ALL_REPOS=coreclr corefx core-setup cli"
for %%i in (%ALL_REPOS%) do (
  echo Pulling %%i
  pushd "%TOP_DIR%\%%i"
  git pull -nq
  popd
)
