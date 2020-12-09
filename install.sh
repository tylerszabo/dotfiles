#!/bin/bash

DATESTAMP=`date +%s`
REPODIR="`dirname \"$0\"`"
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

if echo "$REPODIR" | grep '^\.' &>/dev/null ; then
  REPODIR="`echo \"$REPODIR\" | sed -e 's/^\\.//'`"
  REPODIR="`pwd`$REPODIR"
fi

for i in "$REPODIR/dotfiles/"* ; do
  FILE=`basename "$i"`
  DEST="$HOME/.$FILE"

  PATTERN="`sed -e 's:/:\\\\/:g' <<< "$HOME"`"

  if [ -e "$DEST" -o -h "$DEST" ] ; then
    mv "$DEST" "$DEST".bak-$DATESTAMP
  fi

  ln -s "$i" "$DEST"
done

for i in "$REPODIR/xdg_config/"* ; do
  FILE=`basename "$i"`

  if [ ! -e "$XDG_CONFIG_HOME" ] ; then
    mkdir -p "$XDG_CONFIG_HOME"
  fi

  DEST="$XDG_CONFIG_HOME/$FILE"

  PATTERN="`sed -e 's:/:\\\\/:g' <<< "$HOME"`"

  if [ -e "$DEST" -o -h "$DEST" ] ; then
    mv "$DEST" "$DEST".bak-$DATESTAMP
  fi

  ln -s "$i" "$DEST"
done
