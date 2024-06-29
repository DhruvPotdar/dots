function conda_source
    if test -f /home/radtop/.conda/bin/conda
        eval /home/radtop/.conda/bin/conda "shell.fish" "hook" $argv | source
    end
end