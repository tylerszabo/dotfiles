#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

## never ever beep ever
setopt NO_BEEP

local HOSTCOLOR=cyan
local WHOAMI=`whoami`
[ ${WHOAMI} = 'root' ] && HOSTCOLOR=red
[ ${WHOAMI} = 'tyler' ] && HOSTCOLOR=green
unset RPROMPT
autoload -U promptinit
promptinit
prompt adam2 - blue ${HOSTCOLOR} -

window_title () {
    TITLE="%M:%~$@"
    [[ "$TERM" == "xterm" ]] && print -Pn "\e]0;${TITLE}\a"
}

window_title_exec () {
    window_title "%(!.#.>) ${1}"
}

add-zsh-hook precmd window_title

add-zsh-hook preexec window_title_exec

[[ -e ${HOME}/bin ]] && export PATH="${HOME}/bin:${PATH}"

[[ -e ${HOME}/.shortcuts ]] && source ${HOME}/.shortcuts

[[ -e ${HOME}/.aliases ]] && source ${HOME}/.aliases

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' list-colors ${LS_COLORS}
zstyle ':completion:*' menu select=long
zstyle ':completion:*' use-compctl true

autoload -U compinit
compinit
