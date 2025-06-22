set fish_greeting ''
if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias ls 'eza  --icons always '
alias l 'eza  --icons always'
alias ll 'eza  -la --icons always'
alias c clear
abbr fconf 'nvim ~/.config/fish/config.fish'
abbr dbh 'distrobox enter humble'
abbr dbn 'distrobox enter noetic'

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
# =============== ROS Stuff ===============
if test "$HOME" = /home/radtop/ros1
    # ROS
    source /opt/ros/noetic/share/rosbash/rosfish
    bass source /opt/ros/noetic/setup.bash
    set -x ROS_MASTER_URI 'http://radtop:11311'
    set -x ROS_HOSTNAME radtop
    set -x CATKIN_SHELL bash
    set -x TURTLEBOT3_MODEL waffle
    ulimit -Sn 1024
    ulimit -Hn 524288
    alias tftree "rosrun rqt_tf_tree rqt_tf_tree"
    abbr cb "colcon build"
else if test "$ROS_DISTRO" = humble
    # ROS
    bass source /opt/ros/humble/setup.bash
    # bass source ~/wheelchair_ws/devel/setup.bash
    set -x ROS_MASTER_URI 'http://radtop:11311'
    set -x ROS_DOMAIN_ID 69
    set -x ROS_LOCALHOST_ONLY 1
    set -x ROS_HOSTNAME radtop
    set -x TURTLEBOT3_MODEL waffle
    ulimit -Sn 1024
    ulimit -Hn 524288
    abbr cb "colcon build"
    alias tftree "rosrun rqt_tf_tree rqt_tf_tree"
else
    alias cat bat
    enable_transience
end

# Zoxide settings
zoxide init fish | source

alias nvim-vsc "nvim -u ~/.config/nvim-vsc/init.lua"
# completion/suggestion init
# cod init $fish_pid fish | source
#carapace _carapace | source

# atuin
atuin init fish | source
