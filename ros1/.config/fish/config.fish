set fish_greeting ''
if status is-interactive
    # and not set -q TMUX
    # exec tmux  -u
    # cls
    atuin init fish | source
end

# Alias
alias ls 'eza  --icons'
alias l 'eza  --icons'
alias ll 'eza  -la --icons'
alias c clear
alias fconf 'nvim ~/.config/fish/'

# Set Editor
set -gx EDITOR nvim
set fzf_preview_dir_cmd eza --all --color=always --icons
set fzf_preview_file_cmd bat -nw

set -x PAGER bat

if test "$ZELLIJ" = 0
    function cls
        zellij action clear
    end
else
    function cls
        clear
    end
end
starship init fish | source

zoxide init fish | source


# =============== ROS Stuff ===============
if test "$HOME" = /home/radtop/ros1
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
    alias tftree "rosrun rqt_tf_tree rqt_tf_tree"
    abbr cb "catkin build"
    set PATH $PATH /opt/nvim-linux64/bin
else if test "$ROS_DISTRO" = humble
    # ROS
    bass source /opt/ros/humble/setup.bash
    # bass source ~/wheelchair_ws/devel/setup.bash
    set -x ROS_MASTER_URI 'http://radtop:11311'
    set -x ROS_DOMAIN_ID 69
    set -x ROS_LOCALHOST_ONLY 1
    set -x ROS_HOSTNAME radtop
    # set -x CATKIN_SHELL bash
    set -x TURTLEBOT3_MODEL waffle
    ulimit -Sn 1024
    ulimit -Hn 524288
    bass source /usr/share/colcon_cd/function/colcon_cd.sh
    export _colcon_cd_root=/opt/ros/humble/
    set PATH $PATH /opt/nvim-linux64/bin
else
    alias cat bat
    enable_transience
end

function mini
    set -x NVIM_APPNAME mini
    nvim $argv
end

export GAZEBO_MODEL_PATH=/home/radtop/icra_ws/src/husky_ur3_simulator/models
