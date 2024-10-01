set fish_greeting ''
if status is-interactive
    # and not set -q TMUX
    # exec tmux  -u
    # cls
    atuin init fish | source
end



# Alias
alias ls 'eza  --icons' 
alias ll 'eza  -la --icons' 
# alias bat 'batcat'
alias fconf 'code ~/.config/fish/'
alias cls 'clear'
alias tmux "tmux -u"
# alias code "code-insiders"
alias mux "tmuxinator"
alias px4z " zellij action new-tab --layout ~/.config/zellij/layouts/px4.kdl"

# Set Editor
set -gx EDITOR code
set fzf_preview_dir_cmd eza --all --color=always --icons
set fzf_preview_file_cmd bat -nw

# THE FUCK
# thefuck --alias | source


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# if test -f /home/radtop/.miniconda3/bin/conda
#     eval /home/radtop/.miniconda3/bin/conda "shell.fish" "hook" $argv | source
# end

# <<< conda initialize <<<


# bass source $HOME/.nix-profile/etc/profile.d/nix.sh
bass source "$HOME/.cargo/env"
set PATH $PATH /home/radtop/.cargo/bin /home/radtop/.local/bin /home/radtop/bin /home/radtop/.config/emacs/bin

set -x PAGER bat

# Carpace
# set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
# mkdir -p ~/.config/fish/completions
# carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
# carapace _carapace | source

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

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
 --color=fg:-1,bg:-1,hl:#5f87af
 --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
 --color=info:#ff9305,prompt:#d60088,pointer:#af5fff
 --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'
 
# bind \e\[A fzf-history-widget
# <<< FZF >>> 

starship init fish | source

zoxide init fish | source


# =============== ROS Stuff ===============
if test "$ROS_DISTRO" = "noetic"
  # ROS
  source /opt/ros/noetic/share/rosbash/rosfish
  bass source /opt/ros/noetic/setup.bash
  # bass source ~/wheelchair_ws/devel/setup.bash
  set -x ROS_MASTER_URI 'http://radtop:11311'
  set -x ROS_HOSTNAME 'radtop'
  set -x CATKIN_SHELL bash
  set -x TURTLEBOT3_MODEL "waffle"
  ulimit -Sn 1024
  ulimit -Hn 524288
  alias cat 'batcat'
  alias bat 'batcat'
  alias tftree "rosrun rqt_tf_tree rqt_tf_tree"
  set PATH $PATH /opt/nvim-linux64/bin
else if test "$ROS_DISTRO" = "humble"
  # ROS
  # bass source /opt/ros/humble/share/rosbash/rosfish
  bass source /opt/ros/humble/setup.bash
  # bass source ~/wheelchair_ws/devel/setup.bash
  set -x ROS_MASTER_URI 'http://radtop:11311'
  set -x ROS_DOMAIN_ID '69'
  set -x ROS_LOCALHOST_ONLY 1
  set -x ROS_HOSTNAME 'radtop'
  # set -x CATKIN_SHELL bash
  set -x TURTLEBOT3_MODEL "waffle"
  ulimit -Sn 1024
  ulimit -Hn 524288
  export _colcon_cd_root=/opt/ros/humble/


else
  alias cat 'bat'
  enable_transience
end

#  ============== COLORS =================
# set -U fish_color_normal B3B1AD
# set -U fish_color_command 5f00ff
# set -U fish_color_quote ffaf00
# set -U fish_color_redirection ffff5f
# set -U fish_color_end F29668
# set -U fish_color_error FF3333
# set -U fish_color_param ffffff
# set -U fish_color_comment 767676
# set -U fish_color_match F07178
# set -U fish_color_selection --background=E6B450
# set -U fish_color_search_match --background=E6B450
# set -U fish_color_history_current --bold
# set -U fish_color_operator E6B450
# set -U fish_color_escape 95E6CB
# set -U fish_color_cwd 59C2FF
# set -U fish_color_cwd_root red
# set -U fish_color_valid_path --underline
# set -U fish_color_autosuggestion 8a8a8a
# set -U fish_color_user brgreen
# set -U fish_color_host normal
# set -U fish_color_cancel --reverse
# set -U fish_pager_color_background
# set -U fish_pager_color_prefix normal --bold --underline
# set -U fish_pager_color_progress brwhite --background=cyan
# set -U fish_pager_color_completion normal
# set -U fish_pager_color_description B3A06D
# set -U fish_pager_color_selected_background --background=E6B450
# set -U fish_pager_color_selected_prefix
# set -U fish_pager_color_selected_completion
# set -U fish_pager_color_selected_description
# set -U fish_color_host_remote
# set -U fish_pager_color_secondary_prefix
# set -U fish_color_keyword
# set -U fish_pager_color_secondary_background
# set -U fish_pager_color_secondary_description
# set -U fish_pager_color_secondary_completion

printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "fish" }}\x9c'
export GAZEBO_MODEL_PATH=/home/radtop/icra_ws/src/husky_ur3_simulator/models
