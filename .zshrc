# History
export HISTSIZE=6000
export SAVEHIST=5000
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY

setopt GLOB_DOTS

setopt NO_BEEP

export PATH="/opt/homebrew/opt/node@22/bin:/Users/konstantin/Library/Application Support/Coursier/bin/metals:$PATH"
export EDITOR=hx

# Colors are based on https://github.com/eza-community/eza-themes/blob/main/themes/default.yml
# LS_COLORS are used by completion, fd and other tools
export LS_COLORS='di=34:ln=36:so=31:pi=33:ex=32'
# For ls
export LSCOLORS="exgxbxDxcxegedabagacadah"

# Autocompletion
FPATH="$HOME/.docker/completions:$FPATH"
autoload -Uz compinit
compinit

# zstyle for completions
zstyle ':completion:*' menu select # interactive #search
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}%B-- %d --%b%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:ssh:*:users' ignored-patterns '_*' # Ignore system users starting with _
# zstyle ':completion:*' complete-options true

# Arrow keys access only local history
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
bindkey "^[[A" up-line-or-local-history

down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
bindkey "^[[B" down-line-or-local-history
###

# bat section
# export BAT_THEME="Coldark-Dark"
export BAT_THEME="ansi"
export MANPAGER="col -bx | bat -p -l man"
alias bathelp='bat --plain --language=help'
help() {
    "$@" --help 2>&1 | bathelp
}

alias git='LANG=en_GB git'

alias edit-zshrc="$EDITOR ~/.zshrc"
alias reload-zshrc="source ~/.zshrc"

# eza section
export EZA_ICONS_AUTO=enabled
alias eza="eza --ignore-glob .git"

# provides the ability to change the current working directory when exiting Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

function nucolored() {
	nu -c "open '${1}' | nu-highlight"
}

# == FZF SECTION ==
export FZF_DEFAULT_COMMAND='fd -I -L --type file --type dir --hidden --exclude .git --exclude target --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza -Ta --ignore-glob .git --color=always {} | head -200; else bat -n --color=always --line-range=:200 {}; fi'"

export FZF_ALT_C_COMMAND='fd -I -L --type dir --type symlink --hidden --exclude .git --exclude target --color=always'
export FZF_ALT_C_OPTS="--preview 'eza -Ta --ignore-glob .git --color=always --line-range=:200 {}'"


export FZF_CTRL_R_OPTS='--style=full'

# --ansi is not recommended as default becasue of performance. Can be extracted to per command opt
export FZF_DEFAULT_OPTS="--color=base16 --no-height --no-reverse --ansi"
export FZF_COMPLETION_PATH_OPTS="--preview 'if [ -d {} ]; then eza -Ta --ignore-glob .git --color=always {} | head -200; else bat -n --color=always --line-range=:200 {}; fi'"
export FZF_COMPLETION_DIR_OPTS="--preview 'eza -Ta --ignore-glob .git --color=always {}'"

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

[ -f "/Users/konstantin/.ghcup/env" ] && . "/Users/konstantin/.ghcup/env" # ghcup-env


# Those commands must be at the end of .zshrc
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

