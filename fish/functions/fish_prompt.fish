# ~/Projects/rice ■   (folder name bold, red square)
function fish_prompt
    set -U fish_greeting "Welcome back! (^_~)"
    set -Ux EDITOR nvim
    set -Ux VISUAL nvim
    set -l cwd (string replace -r "^$HOME" "~" $PWD)
    set -l parent (path dirname $cwd)
    set -l base (path basename $cwd)
    if test "$cwd" = "~"
        set parent ""; set base "~"
    else if test "$parent" = "."
        set parent ""
    else
        set parent "$parent/"
    end
    set_color normal; echo -n $parent
    set_color --bold; echo -n $base
    set_color normal; echo -n " "
    set_color red; echo -n "■"
    set_color normal; echo -n " "
    
   alias vault-sync "cd ~/Obsidian; and git add .; and git commit -m 'vault sync'; git push origin main"

end
