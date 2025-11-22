set fish_greeting ''
if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias ls 'eza  --icons always '
alias l 'eza  --icons always'
alias ll 'eza  -la --icons always'
alias c clear
alias btop 'btop --force-utf'
alias kvim 'nvim -u /home/dhruvpotdar/.config/kvim/init.lua'
abbr fconf 'nvim ~/.config/fish/config.fish'
abbr dbr 'distrobox enter ros'
abbr dba 'distrobox enter ati'

set -gx EDITOR nvim
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
if test "$HOME" = /home/dhruvpotdar/ati
    bass source /opt/ros/humble/setup.bash
    abbr ati "cd ~/mule && bass source ~/mule/env.dev.sh && cd -"
    abbr viz "cd ~/mule && bass source ~/mule/env.dev.sh && cd - && streamlit run ~/mule/ati/tools/visualizer/visualizer.py"
else if test "$CONTAINER_ID" = ros
    # ROS
    bass source /opt/ros/humble/setup.bash
    set -gx QT_QPA_PLATFORM xcb
    # bass source ~/wheelchair_ws/devel/setup.bash
    set -x ROS_DISTRO humble
    set -x ROS_MASTER_URI 'http://dhruvpotdar:11311'
    set -x ROS_DOMAIN_ID 69
    set -x ROS_LOCALHOST_ONLY 1
    set -x ROS_HOSTNAME dhruvpotdar
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

atuin init fish | source
