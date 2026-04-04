export PATH="/opt/homebrew/opt/node@22/bin:/Users/konstantin/Library/Application Support/Coursier/bin/metals:$PATH"
export EDITOR=micro

export MANPAGER="col -bx | bat -p -l man"
alias bathelp='bat --plain --language=help'
help() {
    "$@" --help 2>&1 | bathelp
}

alias git='LANG=en_GB git'

# provides the ability to change the current working directory when exiting Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# HSTR configuration - add this to ~/.zshrc
alias hh=hstr                    # hh to be alias for hstr
setopt histignorespace           # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor       # get more colors
bindkey -s "\C-r" "\C-a hstr -- \C-j"     # bind hstr to Ctrl-r (for Vi mode check doc)
export HSTR_TIOCSTI=y
export HISTFILE=~/.zsh_history
