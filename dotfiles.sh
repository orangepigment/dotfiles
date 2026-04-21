#!/usr/bin/env bash

set -euo pipefail

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
    # Strip all starting with :
    destination="${dotfile%%:*}"
    # Strip all ending with :
    source="${dotfile##*:}"
    copy_with_mkdir "$destination" "$source"
  done
  
  brew bundle dump -f --describe
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
  echo "Usage: $0 [-i] [-s] [-h]"
  echo "  -i   Install tools"
  echo "  -a   Apply dotfiles"
  echo "  -s   Save dotfiles"
  echo "  -h   Show this help menu"
}

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

# Handle all expected args in a loop
while getopts ":hisa" opt; do
  case $opt in
    h)
      show_help
      exit 0
    ;;
    i) install ;;
    s) save ;;
    a) apply ;;
    # getopts returns literal ? for unexpected args
    \?) echo "Invalid option -$OPTARG" ;;
  esac
done
