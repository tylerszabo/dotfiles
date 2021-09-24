#!/bin/bash

DATESTAMP=`date +%s`
REPODIR="`dirname \"$0\"`"
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
LOCALE_DIR=$HOME/.locale

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

if [ -e "$LOCALE_DIR" ] ; then
  mv "$LOCALE_DIR" "$LOCALE_DIR".bak-$DATESTAMP
fi
mkdir -p "$LOCALE_DIR"
localedef -f "UTF-8" -i "$REPODIR/locales/en_ZZ" "$LOCALE_DIR/en_ZZ.UTF-8"
localedef -f "UTF-8" -i C "$LOCALE_DIR/C.UTF-8"
localedef -f "UTF-8" -i en_US "$LOCALE_DIR/en_US.UTF-8"
