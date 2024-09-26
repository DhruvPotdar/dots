#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
. "$HOME/.cargo/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# if [[ "$(lsb_release -rs)" == "20.04" ]] && [[ "$(lsb_release -is)" == "Ubuntu" ]]; then
# 	# Replace this with the command you want to execute
# #	fish 
# :
# fi


