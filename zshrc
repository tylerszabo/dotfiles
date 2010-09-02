#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

## never ever beep ever
setopt NO_BEEP


## Configure the prompt

local HOSTCOLOR=cyan
local WHOAMI=`whoami`
[[ ${WHOAMI} == 'root' ]] && HOSTCOLOR=red
[[ ${WHOAMI} == 'tyler' ]] && HOSTCOLOR=green
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


## Configure Path

pathadd () {
  [[ -z ${path[(r)"${1}"]} ]] && [[ -d "${1}" ]] && path=("${1}" "$path[@]")
}

## Add home bin last for highest affinity
pathadd "${HOME}/bin"

## remove dupes just in case and export
typeset -U path
export PATH


## Configure completion

## allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' list-colors ${LS_COLORS}
zstyle ':completion:*' menu select=long
zstyle ':completion:*' use-compctl true

autoload -U compinit
compinit


## Include other files

[[ -e ${HOME}/.shortcuts ]] && source ${HOME}/.shortcuts

[[ -e ${HOME}/.aliases ]] && source ${HOME}/.aliases
