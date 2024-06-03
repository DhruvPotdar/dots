function conda_source
    if test -f /home/radtop/.miniconda3/bin/conda
        eval /home/radtop/.miniconda3/bin/conda "shell.fish" "hook" $argv | source
    end
end