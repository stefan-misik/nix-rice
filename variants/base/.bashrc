#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Activate VI mode
set -o vi


## PROMPT

set_bash_prompt ()
{
    [ $? -eq 0 ] &&
        PROMPT_SYMBOL="\$" ||
        PROMPT_SYMBOL="\[\033[1;31m\]\$\[\e[0m\]"

    PS1="\[\033[1;32m\][\[\e[0m\]\
\u@\h \[\033[1;34m\]\W\
\[\033[1;32m\]]\[\e[0m\]\
${PROMPT_SYMBOL} "
}
PROMPT_COMMAND=set_bash_prompt


## ALIASES

# Set colored LS output
alias ls='ls --color=auto'
# Calendar alias
alias cal='cal -m --week -3'
# 'open' command
alias open='open'


## EXPORTS

# Put ~/.local/bin in the PATH
export PATH="$HOME/.local/bin:$PATH"
# Turn on CLI colors
export CLICOLOR=1
# Set the default editor
export EDITOR=vim


## OTHER
