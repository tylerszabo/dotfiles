#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

## never ever beep ever
setopt NO_BEEP

## Allow for version-aware code
autoload -U is-at-least


## Configure the prompt

local HOSTCOLOR=cyan
local WHOAMI=`whoami`
[[ ${WHOAMI} == 'root' ]] && HOSTCOLOR=red
[[ ${WHOAMI} == 'tyler' ]] && HOSTCOLOR=green
[[ ${WHOAMI} == 'szabo' ]] && HOSTCOLOR=green
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

if is-at-least 4.3.4 ; then
  add-zsh-hook precmd window_title
  add-zsh-hook preexec window_title_exec
else
  precmd () {
    prompt_adam2_precmd
    window_title
    setopt promptsubst
  }
  preexec () {
    prompt_adam2_preexec
    window_title_exec $1
  }
fi


## Configure Path

pathdel() {
  local pos=${path[(i)${1}]}
  [[ ${pos} -le ${#path} ]] && path[${pos}]=()
}

pathadd () {
  [[ -d "${1}" ]] && { pathdel "${1}" ; path=("${1}" "$path[@]") }
}

## Add home bin last for highest affinity
pathadd "${HOME}/bin"

## remove dupes and dead paths then export
typeset -U path
for i in $path ; do
  [[ -d "$i" ]] || pathdel $i
done
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
