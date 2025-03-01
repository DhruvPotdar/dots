set fish_greeting ''
if status is-interactive
    atuin init fish | source
end

# Alias
alias ls 'eza  --icons'
alias ll 'eza  -la --icons'
alias fconf 'nvim ~/.config/fish/'
alias cls clear
alias tmux "tmux -u"
alias mux tmuxinator
alias px4z " zellij action new-tab --layout ~/.config/zellij/layouts/px4.kdl"

# Set Editor
set -gx EDITOR nvim
set fzf_preview_dir_cmd eza --all --color=always --icons
set fzf_preview_file_cmd bat -nw

bass source "$HOME/.cargo/env"
set PATH $PATH $HOME/.cargo/bin $HOME/.local/bin $HOME/bin $HOME/.config/emacs/bin

set -x PAGER bat
starship init fish | source
zoxide init fish | source


if test "$ZELLIJ" = 0
    function cls
        zellij action clear
    end
else
    function cls
        clear
    end
end
# =============== ROS Stuff ===============
if test "$ROS_DISTRO" = noetic

    # ROS
    source /opt/ros/noetic/share/rosbash/rosfish
    bass source /opt/ros/noetic/setup.bash
    # bass source ~/wheelchair_ws/devel/setup.bash
    set -x ROS_MASTER_URI 'http://radtop:11311'
    set -x ROS_HOSTNAME radtop
    set -x CATKIN_SHELL bash
    set -x TURTLEBOT3_MODEL waffle
    ulimit -Sn 1024
    ulimit -Hn 524288
    alias cat batcat
    alias bat batcat
    alias tftree "rosrun rqt_tf_tree rqt_tf_tree"
    set PATH $PATH /opt/nvim-linux64/bin
else if test "$ROS_DISTRO" = humble

    # ROS
    bass source /opt/ros/humble/setup.bash
    bass source $HOME/wheelchair_ws/install/setup.bash
    set -x ROS_MASTER_URI 'http://radtop:11311'
    set -x ROS_DOMAIN_ID 69

    # Better Console Output
    export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity}] [{time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})"
    export RCUTILS_COLORIZED_OUTPUT=1

    set -x ROS_LOCALHOST_ONLY 1
    set -x ROS_HOSTNAME radtop
    set -x TURTLEBOT3_MODEL waffle
    ulimit -Sn 1024
    ulimit -Hn 524288
    bass source /usr/share/gazebo/setup.sh
    enable_transience
    bass source /usr/share/colcon_cd/function/colcon_cd.sh
    export _colcon_cd_root=/opt/ros/humble/
    set PATH $PATH /opt/nvim-linux64/bin
else
    alias cat bat
    enable_transience
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
set QT_QPA_PLATFORMTHEME qt5ct
