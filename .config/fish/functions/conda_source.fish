function conda_source
    if test -f ~/.conda/bin/conda
        eval ~/.conda/bin/conda "shell.fish" hook $argv | source
    end
end

