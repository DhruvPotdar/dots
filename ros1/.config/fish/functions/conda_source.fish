function conda_source
    print $HOME
    if test -f $HOME/.conda/bin/conda
        eval $HOME/.conda/bin/conda "shell.fish" hook $argv | source
    end
end

