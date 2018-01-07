@echo off
set REPO=%~dp0

if not "%1"=="" (
  set REPO=%1
)

IF %REPO:~-1%==\ (
  SET REPO=%REPO:~0,-1%
)

mklink "%USERPROFILE%\_ackrc" "%REPO%\dotfiles\ackrc"
mklink "%USERPROFILE%\.gitconfig" "%REPO%\dotfiles\gitconfig"
mklink "%USERPROFILE%\_vimrc" "%REPO%\dotfiles\vimrc"
mklink /d "%USERPROFILE%\vimfiles" "%REPO%\dotfiles\vim"
