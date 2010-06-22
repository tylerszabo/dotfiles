# Set default file creation to rwxr-x---
umask 022

# Add my local bin to the path
if [ -d "$HOME/bin" ]; then
	export PATH="$HOME/bin:${PATH}"
fi

# Add current directory and junit to the classpath
if [ -n "$CLASSPATH" ]; then
	export CLASSPATH=".:${CLASSPATH}"
	if [ -f "/usr/share/java/junit.jar" ]; then
		export CLASSPATH="${CLASSPATH}:/usr/share/java/junit.jar"
	fi
fi

# Add my local manual pages to the path
if [ -d ~/man ]; then
    MANPATH=~/man${MANPATH:-:}
    export MANPATH
fi


# Stop exectuting here if the shell is non-interactive
[ -z "$PS1" ] && return

# check the window size after each command
shopt -s checkwinsize

# Set up less to read other file formats
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# Set a green command prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Set xterm title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

# Load alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
