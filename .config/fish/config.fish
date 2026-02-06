set fish_greeting ''
if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias ls 'eza  --icons always '
alias lm 'eza  --icons always ~ | grep mule'
alias l 'eza  --icons always'
alias ll 'eza  -la --icons always'
alias c clear
alias cat bat
# alias btop 'btop --force-utf'
abbr fconf 'nvim ~/.config/fish/config.fish'

set -gx EDITOR nvim
set -x MANPAGER "nvim +Man!"
set -x MANWIDTH 999

if test "$ZELLIJ" = 0
    function cls
        zellij action clear
    end
else
    function cls
        clear
    end
end

abbr gs "git status"

abbr ati "cd ~/mule && bass source ~/mule/env.dev.sh"

function viz
    cd ~/mule 
    bass source env.dev.sh
    cd ati/schema; protoc --python_out=. messages.proto
    streamlit run ~/mule/ati/tools/visualizer/visualizer.py
    cd -
end

function gl
    git log --graph --date=relative \
        --pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s %C(dim white)- %an, %ar'
end

function ros
    # ROS
    bass source /opt/ros/humble/setup.bash
    set -gx QT_QPA_PLATFORM xcb
    set -x ROS_MASTER_URI 'http://dhruvpotdar:11311'
    set -x ROS_DOMAIN_ID 69
    set -x ROS_LOCALHOST_ONLY 1
    # set -x ROS_HOSTNAME dhruvpotdar
    # ulimit -Sn 1024
    # ulimit -Hn 524288
    abbr cb "colcon build"
    alias tftree "rosrun rqt_tf_tree rqt_tf_tree"
end

# Sourcing apps 
zoxide init fish | source
atuin init fish | source
starship init fish | source

# opencode
fish_add_path /home/dhruvpotdar/.opencode/bin
