# The window / tab title, shown in the bar: "~/P/rice main★"  (or "nvim — ~/P/rice" while a program runs)
function fish_title
    set -l where (prompt_pwd -d 1)
    if set -q argv[1]
        echo "$argv[1] — $where"
        return
    end
    set -l g (command "$HOME/.local/bin/rice-git" 2>/dev/null | string split ' ')[1]
    if test -n "$g"
        echo "$where $g"
    else
        echo "$where"
    end
end
