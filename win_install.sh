#!/bin/sh

CYG_USERPROFILE=`cygpath "$USERPROFILE"/`

DATESTAMP=`date +%s`

# Must be Administrator to use MKLINK
if ! id | grep -q '\<544\>' 2>/dev/null ; then
  echo Not Administrator >&2
  exit 1
fi

if [ -e "$CYG_USERPROFILE/_vimrc" ] ; then
  mv "$CYG_USERPROFILE/_vimrc" "$CYG_USERPROFILE/_vimrc.bak-$DATESTAMP"
fi

if [ -e "$CYG_USERPROFILE/vimfiles" ] ; then
  mv "$CYG_USERPROFILE/vimfiles" "$CYG_USERPROFILE/vimfiles.bak-$DATESTAMP"
fi

cmd /c "MKLINK %USERPROFILE%\\_vimrc `cygpath -a -w dotfiles/vimrc`"
cmd /c "MKLINK /D %USERPROFILE%\\vimfiles `cygpath -a -w dotfiles/vim`"
