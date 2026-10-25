#!/usr/bin/env zsh

set -euo pipefail

script_name=$0

DOTFILES=(
    "$HOME/.zshrc:.zshrc"
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty:ghostty.config"
    "$HOME/.config/starship.toml:starship.toml"
    "$HOME/.config/yazi/yazi.toml:yazi.toml"
    "$HOME/.config/zed/settings.json:zed/settings.json"
    "$HOME/.config/zed/keymap.json:zed/keymap.json"
    "$HOME/.config/macchina/macchina.toml:macchina/macchina.toml"
    "$HOME/.config/macchina/themes/Cadmium.toml:macchina/themes/Cadmium.toml"
    "$HOME/.config/helix:helix"
    "$HOME/Library/Application Support/nushell/config.nu:nushell/config.nu"
)

copy_with_mkdir() {
    source="$1"
    destination="$2"

    if [[ -d "$source" ]]; then
        mkdir -p "$destination"
        cp -Ra "$source"/* "$destination"
    else
        dest_dir=$(dirname "$destination")
        mkdir -p "$dest_dir"
        cp -a "$source" "$destination"
    fi
}

save() {
    for dotfile in "${DOTFILES[@]}"; do
        # Strip ':' and everything after it
        system_files="${dotfile%%:*}"
        # Strip everything up to and including ':' 
        repo_files="${dotfile##*:}"
        copy_with_mkdir "${system_files}" "${repo_files}"
    done

    brew bundle dump -f
    echo "Dotfiles and Brewmake saved"
}

install() {
    if [[ $(command -v brew) == "" ]]; then
        echo "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        PATH="/opt/homebrew/bin:$PATH"
    else
        echo "Updating Homebrew"
        brew update
    fi

    echo "Installing brew packages"
    brew bundle

    echo "Tools installed"
}

show_help() {
    echo "Usage: ${script_name} ([-a] [-i]) | [-s] | [-h]"
    echo "  -i, --install   Install tools"
    echo "  -a, --aply      Apply dotfiles"
    echo "  -s, --save      Save dotfiles"
    echo "  -h, --help      Show this help menu"
}

local apply install save help

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Brace expansions are great for specifying short and long
# option names without duplicating any information.
zparseopts -D -F -K - \
    {i,-install}=install \
    {a,-apply}=apply \
    {s,-save}=save \
    {h,-help}=help || show_help

# Presence of options can be checked via (( $#option )).
if (($#help)); then
    show_help
    exit 0
fi

if (($#save)) && ( (($#apply)) || (($#install))); then
    echo "--save option is incompatible with --apply and --install options"
    show_help
    exit 1
fi

if (($#save)); then
    save
fi

if (($#apply)); then
    apply
fi

if (($#install)); then
    install
fi
