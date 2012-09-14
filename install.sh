#!/bin/sh

REPODIR="`dirname \"$0\"`"

if grep '^\.' <<< "$REPODIR" &>/dev/null ; then
  REPODIR="`sed -e 's/^\\.//' <<< \"$REPODIR\"`"
  REPODIR="`pwd`$REPODIR"
fi

for i in "$REPODIR/dotfiles/"* ; do
  FILE=`basename "$i"`
  DEST="$HOME/.$FILE"

  PATTERN="`sed -e 's:/:\\\\/:g' <<< "$HOME"`"

  TARGET="`sed -e \"s/^$PATTERN\\///\" <<< \"$i\"`"
  
  if [ -e "$DEST" ] ; then
    mv "$DEST" "$DEST".bak-`date +%s`
  fi
  ln -s "$TARGET" "$DEST"
done
