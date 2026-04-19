setopt HIST_IGNORE_SPACE
setopt nobeep

export PATH="/opt/homebrew/opt/node@22/bin:/Users/konstantin/Library/Application Support/Coursier/bin/metals:$PATH"
export EDITOR=hx

export MANPAGER="col -bx | bat -p -l man"
alias bathelp='bat --plain --language=help'
help() {
    "$@" --help 2>&1 | bathelp
}

alias git='LANG=en_GB git'

alias eza="eza --icons --ignore-glob .git"

# provides the ability to change the current working directory when exiting Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Fix filenames with whitespace handling
function nucolored() {
	nu -c "open $1 | nu-highlight"
}

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

# == FZF SECTION ==
export FZF_DEFAULT_COMMAND='fd -I -L --type file --type dir --hidden --exclude .git --exclude target --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza -TDa --ignore-glob .git --color=always {}; else bat -n --color=always {}; fi'"

export FZF_ALT_C_COMMAND='fd -I -L --type dir --type symlink --hidden --exclude .git --exclude target --color=always'
export FZF_ALT_C_OPTS="--preview 'eza -TDa --ignore-glob .git --color=always {}'"


export FZF_CTRL_R_OPTS='--scheme=history'

# --ansi is not recommended as default becasue of performance. Can be extracted to per command opt
export FZF_DEFAULT_OPTS="--no-height --no-reverse --ansi"
export FZF_COMPLETION_PATH_OPTS="--preview 'if [ -d {} ]; then eza -TDa --ignore-glob .git --color=always {}; else bat -n --color=always {}; fi'"
export FZF_COMPLETION_DIR_OPTS="--preview 'eza -TDa --ignore-glob .git --color=always {}'"

# Use fd for listing path candidates.
_fzf_compgen_path() {
  fd -I -L --type file --type dir --hidden --exclude ".git" --exclude target --color=always . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd -I -L --type dir --type symlink --hidden --exclude ".git" --exclude target --color=always . "$1"
}

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# == FZF SECTION END ===

eval "$(zoxide init zsh)"

[ -f "/Users/konstantin/.ghcup/env" ] && . "/Users/konstantin/.ghcup/env" # ghcup-env

