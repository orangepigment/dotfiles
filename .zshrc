# History
export HISTSIZE=6000
export SAVEHIST=5000
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY

# Expansions
setopt GLOB_DOTS

setopt NO_BEEP

# Set uniquniess for PATH and fpath
typeset -U PATH
typeset -U fpath

export PATH="$HOME/Library/Application Support/Coursier/bin/metals:$HOME/.local/bin:$PATH"
export EDITOR=hx

# Colors are based on https://github.com/eza-community/eza-themes/blob/main/themes/default.yml
# LS_COLORS are used by completion, fd and other tools
export LS_COLORS='di=34:ln=36:so=31:pi=33:ex=32'
# For ls
export LSCOLORS="exgxbxDxcxegedabagacadah"

# Setup fpath for autoloading
fpath=("$HOME/Library/Application Support/ScalaCli/completions/zsh" $HOME/.docker/completions $HOME/.completions $fpath)

# Autocompletion section
autoload -U compinit
compinit

# Disable autocomplete for java
compdef -d java

# zstyle for completions
zstyle ':completion:*' menu select # interactive #search
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}%B-- %d --%b%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:ssh:*:users' ignored-patterns '_*' # Ignore system users starting with _
###

# run-help override, unalias will print error on sourcig zshrc when alias is already removed, so dev-null stderr
unalias run-help 2>/dev/null
autoload -U run-help

# Keybindings section
# ZLE custom keybindings
autoload -U edit-command-line
zle -N edit-command-line        # Install widget
bindkey "^[e" edit-command-line # Alt-e

# Arrow keys access only local history
up-line-or-local-history() {
  zle set-local-history 1
  zle up-line-or-search
  zle set-local-history 0
}
zle -N up-line-or-local-history
bindkey "^[[A" up-line-or-local-history

down-line-or-local-history() {
  zle set-local-history 1
  zle down-line-or-search
  zle set-local-history 0
}
zle -N down-line-or-local-history
bindkey "^[[B" down-line-or-local-history
###

# Aliases and aliasing functions
alias git='LANG=en_GB git'

alias edit-zshrc="$EDITOR ~/.zshrc"
alias reload-zshrc="source ~/.zshrc"

alias cd="z"
function hike() {
  if [[ ${#} -ne 1 ]]; then
    echo "Wrong number of arguments. Exactly one directory path expected!"
    return 1
  fi
  mkdir -p "${1}" && z "${1}"
}
###

export LEAF_THEME="gruvbox"
export MDCAT_THEME="gruvbox-dark"

# bat section
export BAT_THEME="gruvbox-dark"
export MANPAGER="col -bx | bat -p -l man"
alias bathelp='bat --plain --language=help'
function help() {
  "$@" --help 2>&1 | bathelp
}
###

# eza section
export EZA_ICONS_AUTO=enabled
alias eza="eza --ignore-glob .git"
###

# provides the ability to change the current working directory when exiting Yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

function nucolored() {
  nu -c "open '${1}' | nu-highlight"
}

# === FZF SECTION ==
# morhetz/gruvbox
local FZF_GRUVBOX="--color=bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934"
# --ansi is not recommended as default because of performance. Can be extracted to per command opt
export FZF_DEFAULT_OPTS="--no-height --no-reverse --highlight-line --ansi ${FZF_GRUVBOX}"

local EZA_IGNORE='--ignore-glob "Applications|Library|.git|.aspnet|.cabal|.cache|.cargo|.cups|.dart|.dart-tool|.dartServer|.docker|.dotnet|.ghcup|.gradle|.homebrew|.ipython|.ivy2|.local|.metals|.mill|.npm|.pub-cache|.rustup|.sbt|.stack|.terminfo|.thumbnails|.Trash|.venv|.wine|.yandex|.DS_Store"'

local FZF_EZA_PREVIEW_COMMAND="eza -Ta ${EZA_IGNORE} --color=always {}"
local FZF_DIR_PREVIEW_OPTS="--preview '${FZF_EZA_PREVIEW_COMMAND}'"
local FZF_PATH_PREVIEW_OPTS="--preview 'if [ -d {} ]; then ${FZF_EZA_PREVIEW_COMMAND}; else bat -n --color=always --line-range=:200 {}; fi'"

# Default command to use when input is tty
export FZF_DEFAULT_COMMAND="fd -I --hidden --follow --exclude ".git" --color=always"

# Ctrl-T Paste the selected files and directories onto the command-line
export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
export FZF_CTRL_T_OPTS=${FZF_PATH_PREVIEW_OPTS}

# Alt-C cd into the selected directory
export FZF_ALT_C_COMMAND="fd -I --type dir --hidden --follow --exclude '.git'"
export FZF_ALT_C_OPTS="--preview '${FZF_EZA_PREVIEW_COMMAND}'"

# Ctrl-R Paste the selected command from history onto the command-line
export FZF_CTRL_R_OPTS='--style=full'

export FZF_COMPLETION_PATH_OPTS=${FZF_PATH_PREVIEW_OPTS}
export FZF_COMPLETION_DIR_OPTS=${FZF_PATH_PREVIEW_OPTS}

# Use fd for listing path candidates
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type dir --hidden --follow --exclude ".git" . "$1"
}

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

function brew-search-install() {
  # Outer parenthesis capture output into an array
  local selection=($(brew search ${@} | fzf -m --preview 'brew info {}'))
  if [[ ${#selection} -ne 0 ]]; then
    brew install ${selection}
  else
    echo 'No packages selected for installation'
  fi
}

# === FZF SECTION END ===

[ -f "/Users/konstantin/.ghcup/env" ] && . "/Users/konstantin/.ghcup/env" # ghcup-env

# Those commands must be at the end of .zshrc
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(zsh-patina activate)"

