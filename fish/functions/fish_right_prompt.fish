# main★ ↑1 +2 ~3 ?4 · 11:23   (italic, dim)  Git details only appear inside a git folder (bin/rice-git).
function fish_right_prompt
    set_color --italics brblack
    set -l g (command "$HOME/.local/bin/rice-git" 2>/dev/null)
    test -n "$g"; and echo -n "$g · "
    echo -n (date +%H:%M)
    set_color normal
end
