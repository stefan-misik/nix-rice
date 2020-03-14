#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Activate VI mode
set -o vi

UNAMESTR=`uname`
if [[ "${UNAMESTR}" == "FreeBSD" ]] || \
[[ "${UNAMESTR}" == "Darwin" ]] ; then
	# Set colored LS output
	alias ls='ls -G'
	# Set colors to GNU-like look
	export LSCOLORS=ExGxFxdxCxdxdxabagacac
    # Bash completion on macOS
    if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
        . /opt/local/etc/profile.d/bash_completion.sh
    fi
else
	# Set colored LS output
	alias ls='ls --color=auto'
fi

# 'open' command for cygwin
if [[ "${UNAMESTR}" == "Darwin" ]] ; then
    alias open='open'
elif [[ "$(expr substr ${UNAMESTR} 1 6)" == "CYGWIN" ]] ; then
	alias open='cygstart'
	alias sudo='cygstart -a runas'
else
	if [[ "${UNAMESTR}" == "Linux" ]] ; then
		alias open='xdg-open'
	fi
fi

# Calendar alias
alias cal='cal -m --week -3'

# Turn on CLI colors
export CLICOLOR=1

# Set the default editor
export EDITOR=vim

# Bash prompt function
function set_bash_prompt()
{
	if [ $? -eq 0 ] ; then
		PROMPT_SYMBOL="\$"
	else
		PROMPT_SYMBOL="\[\033[1;31m\]\$\[\e[0m\]"
	fi

	PS1="\[\033[1;32m\][\[\e[0m\]\u@\h \[\033[1;34m\]\W\[\033[1;32m\]]\[\e[0m\]${PROMPT_SYMBOL} "	
	
	
}
PROMPT_COMMAND=set_bash_prompt

