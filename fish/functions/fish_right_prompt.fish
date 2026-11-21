# main★ · 11:23   (italic, dim)
function fish_right_prompt
    set_color --italics brblack
    set -l branch (git branch --show-current 2>/dev/null)
    if test -n "$branch"
        set -l dirty ""
        git diff --quiet --ignore-submodules HEAD 2>/dev/null; or set dirty "★"
        echo -n "$branch$dirty · "
    end
    echo -n (date +%H:%M)
    set_color normal
end
