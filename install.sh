#!/bin/sh

REPODIR="`dirname \"$0\"`"

if echo "$REPODIR" | grep '^\.' &>/dev/null ; then
  REPODIR="`echo \"$REPODIR\" | sed -e 's/^\\.//'`"
  REPODIR="`pwd`$REPODIR"
fi

for i in "$REPODIR/dotfiles/"* ; do
  FILE=`basename "$i"`
  DEST="$HOME/.$FILE"

  PATTERN="`sed -e 's:/:\\\\/:g' <<< "$HOME"`"

  TARGET="`sed -e \"s/^$PATTERN\\///\" <<< \"$i\"`"
  
  if [ -e "$DEST" -o -h "$DEST" ] ; then
    DATESTAMP=`date +%s`
    echo mv "$DEST" "$DEST".bak-$DATESTAMP
  fi
  echo ln -s "$TARGET" "$DEST"
done
