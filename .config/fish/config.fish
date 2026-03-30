set fish_greeting ''
if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    # Manually ensure kitty integration is loaded AFTER starship
    # if set -q KITTY_INSTALLATION_DIR
    #     source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    #     set -g kitty_shell_integration enabled
    # end
end

alias ls 'eza  --icons always '
alias lm 'eza  --icons always ~ | rg mule'
alias l 'eza  --icons always'
alias ll 'eza  -la --icons always'
alias c clear
alias cat bat
alias lg lazygit
# alias btop 'btop --force-utf'
abbr fconf 'nvim ~/.config/fish/config.fish'

set -gx EDITOR nvim
set -x MANPAGER "nvim +Man!"
set -x MANWIDTH 999

alias cls clear

abbr gs "git status"


function ati
    set curr_dir $PWD
    cd ~/mule 
    bass source env.dev.sh
    cd $curr_dir

    # Temporary, needed for acados in mpc
    set -x ACADOS_SOURCE_DIR $HOME/repos/acados
    set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH $ACADOS_SOURCE_DIR/lib
end

function viz
    set curr_dir $PWD
    cd ~/mule 
    echo "Current Branch: $(git branch --show-current)"
    bass source env.dev.sh
    if test -e ati/core
        cd ati/common/schema; protoc --python_out=. messages.proto
        cd ../../..
    else
        cd ati/schema; protoc --python_out=. messages.proto
        cd ../..
    end
    cd
    streamlit run ~/mule/ati/tools/visualizer/visualizer.py
    echo $curr_dir
    cd $curr_dir
end

function kconf
    cd ~/.config/kitty
    nvim kitty.conf
end

function gl
    git log --graph --date=relative \
        --pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s %C(dim white)- %an, %ar'
end

# function ros
#     # ROS
#     source ~/.config/fish/ros2.fish
#     set -gx QT_QPA_PLATFORM xcb
#     set -x ROS_MASTER_URI 'http://dhruvpotdar:11311'
#     # set -x ROS_DOMAIN_ID 69
#     set -x ROS_LOCALHOST_ONLY 1
#     # set -x ROS_HOSTNAME dhruvpotdar
#     # ulimit -Sn 1024
#     # ulimit -Hn 524288
#     abbr cb "colcon build"
#     # alias tftree "rosrun rqt_tf_tree rqt_tf_tree"
#     # alias rr "ros2 run $(ros2 pkg executables | fzf | string split ' ')"
#     abbr cb "colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON --symlink-install"
#
# end

# function starship_transient_prompt_func
#   starship module character
# end

function starship_transient_rprompt_func
  starship module time
end

# sourcing apps 
zoxide init fish | source
atuin init fish | source
starship init fish | source
enable_transience

# opencode
fish_add_path /home/dhruvpotdar/.opencode/bin
