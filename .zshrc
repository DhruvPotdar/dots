# zsh Aliases
alias ls='eza  --icons' 
alias ll='eza  -la --icons' 
alias bat='batcat'
alias cat='batcat'
alias cls='clear'
alias tftree="rosrun rqt_tf_tree rqt_tf_tree"
alias tmux="tmux -u"
# alias code="code-insiders"
alias mux="tmuxinator"

source "$HOME/.cargo/env"
export PATH=$PATH:/home/radtop/.local/bin
eval "$(zoxide init zsh)"
# <<< Plugins and Settings >>>

source ~/.zsh/fzf-tab-completion/zsh/fzf-zsh-completion.sh
bindkey '^I' fzf_completion
[ ! -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] || source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6e6e6e,bold,underline"

source /home/radtop/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source /home/radtop/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fpath=(~/.zsh/zsh-completions/src $fpath)



zstyle ':autocomplete:*' default-context ''
zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:*' list-lines 20
zstyle ':autocomplete:history-search:*' list-lines 100
zstyle ':autocomplete:*' insert-unambiguous yes
zstyle ':autocomplete:*' fzf-completion yes
zstyle ':autocomplete:*' add-space \
    executables aliases functions builtins reserved-words commands
zstyle ':autocomplete:*' recent-dirs zoxide
# all Tab widgets
zstyle ':autocomplete:*complete*:*' insert-unambiguous yes
# all history widgets
zstyle ':autocomplete:*history*:*' insert-unambiguous yes
zstyle ':autocomplete:menu-search:*' insert-unambiguous yes
zstyle ':completion:*' list-colors ''



# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'


HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory autocd extendedglob notify correctall nomatch globdots


export TURTLEBOT3_MODEL=burger
export ROS_MASTER_URI='http://radtop:11311'
export ROS_HOSTNAME='radtop'
source /opt/ros/noetic/setup.zsh
source ~/catkin_ws/devel/setup.zsh
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:~/Drone-Mapping/drone_slam/models
export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:~/Drone-Mapping/external/velodyne_gazebo_plugins/build/devel/lib


export EDITOR=code-insiders
# Prompt
eval "$(starship init zsh)"

bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey -M menuselect '\r' accept-line
bindkey '^[[A' fzf-history-widget
# bindkey "${key[Up]}" fzf-history-widget
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/radtop/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/radtop/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/radtop/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/radtop/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

#  <<< FZF >>>
export FZF_CTRL_T_OPTS="
  --preview 'batcat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_DEFAULT_OPTS=' --border double'
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --border double
  "
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
 --color=fg:-1,bg:-1,hl:#5f87af
 --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
 --color=info:#ff9305,prompt:#d60088,pointer:#af5fff
 --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'
# <<< FZF >>> 


# if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#     tmux attach -t default || tmux new -s default
# fi



eval "$(atuin init zsh)"
