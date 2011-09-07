#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

## set Vi mode
bindkey -v

## never ever beep ever
setopt NO_BEEP

## Allow for version-aware code
autoload +XUz is-at-least 2>/dev/null || {
  is-at-least () {
    return -1
  }
}


## Configure the prompt

local HOSTCOLOR=cyan
local WHOAMI=`whoami`
[[ ${WHOAMI} == 'root' ]] && HOSTCOLOR=red
[[ ${WHOAMI} == 'tyler' ]] && HOSTCOLOR=green
[[ ${WHOAMI} == 'szabo' ]] && HOSTCOLOR=green
unset RPROMPT
autoload -Uz promptinit
promptinit
prompt adam2 black blue ${HOSTCOLOR} black

window_title () {
  TITLE="%M:%~$@"
  [[ "$TERM" == "xterm" ]] && print -Pn "\e]0;${TITLE}\a"
}

window_title_exec () {
  window_title "%(!.#.>) ${1}"
}


## Put version control into PS1

autoload +XUz vcs_info 2>/dev/null || {
  vcs_info () {
    return -1
  }
} && {
  zstyle ':vcs_info:*' stagedstr '+'
  zstyle ':vcs_info:*' unstagedstr '*'
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' formats '(%s)-(%b%u%c)'
  zstyle ':vcs_info:*' actionformats '(%s)-(%b%u%c|%a)'

  # Use git completion for git PS1
  zstyle ':vcs_info:*' disable git
}

__versioncontrol_ps1 () {
  # Use git completion for git PS1
  echo -n "$(__git_ps1 '-(git)-(%s)')"

  if vcs_info ; then
    echo -n "-${vcs_info_msg_0_}"
  else
    echo -n "$(__svn_ps1 '-(svn)-(%s)')"
  fi
}

export prompt_line_1a_orig="$prompt_line_1a"
versioncontrol_prompt() {
  if [[ -n "$prompt_line_1a_orig" ]] ; then
    export prompt_line_1a="$prompt_line_1a_orig$(__versioncontrol_ps1)"
  fi
}


## Configure hooks

if is-at-least 4.3.9 ; then
  add-zsh-hook -d precmd prompt_adam2_precmd
  add-zsh-hook precmd versioncontrol_prompt
  add-zsh-hook precmd prompt_adam2_precmd
  add-zsh-hook precmd window_title

  add-zsh-hook preexec window_title_exec
else
  precmd () {
    versioncontrol_prompt
    prompt_adam2_precmd
    window_title
    setopt promptsubst
  }
  preexec () {
    prompt_adam2_preexec
    window_title_exec $1
  }
fi


## Configure History

export HISTFILE=~/.zsh_history
export HISTSIZE=25000
export SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY


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


## SVN PS1
# Really basic

__svn_ps1() {
  if svn info --non-interactive &>/dev/null ; then
    local rev=`svn info --non-interactive | awk '/Revision:/ {print $2}'`
    local branchtag=""
    local flag_changed=`{svn status | grep '.'} &>/dev/null && echo -n \*`

    local flags=$flag_changed
		printf "${1:- (%s)}" "${branchtag:+$branchtag:}$rev${flags:+ $flags}"
  fi
}


## Include Git completion content directly for now

# Options for git thing
GIT_PS1_SHOWDIRTYSTATE="yes" # *=unstaged, +=staged
GIT_PS1_SHOWSTASHSTATE="yes" # $=stashed
GIT_PS1_SHOWUNTRACKEDFILES="yes" # %=untracked
# Portion of git-completion.bash with slight modifications for ZSH. Original copyright
# notice follows:
#
# bash completion support for core Git.
#
# Copyright (C) 2006,2007 Shawn O. Pearce <spearce@spearce.org>
# Conceptually based on gitcompletion (http://gitweb.hawaga.org.uk/).
# Distributed under the GNU General Public License, version 2.0.
#
# The contained completion routines provide support for completing:
#
#    *) local and remote branch names
#    *) local and remote tag names
#    *) .git/remotes file names
#    *) git 'subcommands'
#    *) tree paths within 'ref:path/to/file' expressions
#    *) common --long-options
#
# To use these routines:
#
#    1) Copy this file to somewhere (e.g. ~/.git-completion.sh).
#    2) Added the following line to your .bashrc:
#        source ~/.git-completion.sh
#
#    3) Consider changing your PS1 to also show the current branch:
#        PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
#
#       The argument to __git_ps1 will be displayed only if you
#       are currently in a git repository.  The %s token will be
#       the name of the current branch.
#
#       In addition, if you set GIT_PS1_SHOWDIRTYSTATE to a nonempty
#       value, unstaged (*) and staged (+) changes will be shown next
#       to the branch name.  You can configure this per-repository
#       with the bash.showDirtyState variable, which defaults to true
#       once GIT_PS1_SHOWDIRTYSTATE is enabled.
#
#       You can also see if currently something is stashed, by setting
#       GIT_PS1_SHOWSTASHSTATE to a nonempty value. If something is stashed,
#       then a '$' will be shown next to the branch name.
#
#       If you would like to see if there're untracked files, then you can
#       set GIT_PS1_SHOWUNTRACKEDFILES to a nonempty value. If there're
#       untracked files, then a '%' will be shown next to the branch name.
#
# To submit patches:
#
#    *) Read Documentation/SubmittingPatches
#    *) Send all patches to the current maintainer:
#
#       "Shawn O. Pearce" <spearce@spearce.org>
#
#    *) Always CC the Git mailing list:
#
#       git@vger.kernel.org
#

case "$COMP_WORDBREAKS" in
*:*) : great ;;
*)   COMP_WORDBREAKS="$COMP_WORDBREAKS:"
esac

# __gitdir accepts 0 or 1 arguments (i.e., location)
# returns location of .git repo
__gitdir ()
{
	if [ -z "${1-}" ]; then
		if [ -n "${__git_dir-}" ]; then
			echo "$__git_dir"
		elif [ -d .git ]; then
			echo .git
		else
			git rev-parse --git-dir 2>/dev/null
		fi
	elif [ -d "$1/.git" ]; then
		echo "$1/.git"
	else
		echo "$1"
	fi
}

# __git_ps1 accepts 0 or 1 arguments (i.e., format string)
# returns text to add to bash PS1 prompt (includes branch name)
__git_ps1 ()
{
	local g="$(__gitdir)"
	if [ -n "$g" ]; then
		local r
		local b
		if [ -f "$g/rebase-merge/interactive" ]; then
			r="|REBASE-i"
			b="$(cat "$g/rebase-merge/head-name")"
		elif [ -d "$g/rebase-merge" ]; then
			r="|REBASE-m"
			b="$(cat "$g/rebase-merge/head-name")"
		else
			if [ -d "$g/rebase-apply" ]; then
				if [ -f "$g/rebase-apply/rebasing" ]; then
					r="|REBASE"
				elif [ -f "$g/rebase-apply/applying" ]; then
					r="|AM"
				else
					r="|AM/REBASE"
				fi
			elif [ -f "$g/MERGE_HEAD" ]; then
				r="|MERGING"
			elif [ -f "$g/BISECT_LOG" ]; then
				r="|BISECTING"
			fi

			b="$(git symbolic-ref HEAD 2>/dev/null)" || {

				b="$(
				case "${GIT_PS1_DESCRIBE_STYLE-}" in
				(contains)
					git describe --contains HEAD ;;
				(branch)
					git describe --contains --all HEAD ;;
				(describe)
					git describe HEAD ;;
				(* | default)
					git describe --exact-match HEAD ;;
				esac 2>/dev/null)" ||

				b="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." ||
				b="unknown"
				b="($b)"
			}
		fi

		local w
		local i
		local s
		local u
		local c

		if [ "true" = "$(git rev-parse --is-inside-git-dir 2>/dev/null)" ]; then
			if [ "true" = "$(git rev-parse --is-bare-repository 2>/dev/null)" ]; then
				c="BARE:"
			else
				b="GIT_DIR!"
			fi
		elif [ "true" = "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
			if [ -n "${GIT_PS1_SHOWDIRTYSTATE-}" ]; then
				if [ "$(git config --bool bash.showDirtyState)" != "false" ]; then
					git diff --no-ext-diff --quiet --exit-code || w="*"
					if git rev-parse --quiet --verify HEAD >/dev/null; then
						git diff-index --cached --quiet HEAD -- || i="+"
					else
						i="#"
					fi
				fi
			fi
			if [ -n "${GIT_PS1_SHOWSTASHSTATE-}" ]; then
			        git rev-parse --verify refs/stash >/dev/null 2>&1 && s="$"
			fi

			if [ -n "${GIT_PS1_SHOWUNTRACKEDFILES-}" ]; then
			   if [ -n "$(git ls-files --others --exclude-standard)" ]; then
			      u="%%"
			   fi
			fi
		fi

		local f="$w$i$s$u"
		printf "${1:- (%s)}" "$c${b##refs/heads/}${f:+ $f}$r"
	fi
}
