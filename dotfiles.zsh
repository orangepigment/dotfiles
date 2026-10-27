#!/usr/bin/env zsh

set -euo pipefail

readonly script_name=$0

readonly DOTFILES=(
  "$HOME/.zshrc:.zshrc"
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty:ghostty.config"
  "$HOME/Library/Application Support/nushell/config.nu:nushell/config.nu"
  "$HOME/.config/starship.toml:starship.toml"
  "$HOME/.config/yazi/yazi.toml:yazi.toml"
  "$HOME/.config/zed/settings.json:zed/settings.json"
  "$HOME/.config/zed/keymap.json:zed/keymap.json"
  "$HOME/.config/macchina/macchina.toml:macchina/macchina.toml"
  "$HOME/.config/macchina/themes/Cadmium.toml:macchina/themes/Cadmium.toml"
  "$HOME/.config/helix:helix"
  "$HOME/.config/delta/themes.gitconfig:delta/themes.gitconfig"
  "$HOME/.config/tombi/config.toml:tombi/config.toml"
  "$HOME/.config/dprint/dprint.jsonc:dprint/dprint.jsonc"
  "$HOME/Code/scripts/bat-theme-preview.sh:scripts/bat-theme-preview.sh"
  "$HOME/Code/scripts/delta-custom-theme-preview.zsh:scripts/delta-custom-theme-preview.zsh"
  "$HOME/Code/scripts/delta-theme-preview.zsh:scripts/delta-theme-preview.zsh"
  "$HOME/Code/scripts/dump-helix-health.nu:scripts/dump-helix-health.nu"
  "$HOME/Code/scripts/netcat-http-server.zsh:scripts/netcat-http-server.zsh"
  "$HOME/Code/scripts/print-ansi-colors.zsh:scripts/print-ansi-colors.zsh"
  "$HOME/Code/scripts/save-zsh-keybindings.nu:scripts/save-zsh-keybindings.nu"
)

readonly COMPL_DIR="${HOME}/.completions"

readonly zsh_completions_base_url="https://raw.githubusercontent.com/zsh-users/zsh-completions/refs/heads/master/src/"

readonly completion_urls=(
  "${zsh_completions_base_url}_nu"
  "${zsh_completions_base_url}_sbt"
  "${zsh_completions_base_url}_scala"
  "https://raw.githubusercontent.com/mosquito/docker-compose/refs/heads/master/contrib/completion/zsh/_docker-compose"
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
  for dotfile in ${DOTFILES}; do
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
  if [[ -z $(command -v brew) ]]; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    PATH="/opt/homebrew/bin:$PATH"
  else
    echo "Updating Homebrew"
    brew update
  fi

  echo "Installing brew packages"
  brew bundle

  echo "Updating git config"
  git config --global include.path '~/.config/delta/themes.gitconfig'

  git config --global core.autocrlf input
  git config --global core.editor hx
  git config --global core.pager delta
  git config --global init.defaultBranch main
  git config --global merge.conflictStyle zdiff3

  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.features 'gruvmax-fang'
  git config --global --comment 'use n and N to move between diff sections' delta.navigate 'true'
  git config --global delta.line-numbers 'true'
  git config --global delta.side-by-side 'true'

  git config --global alias.st status

  echo "Extra completions setup"
  setup_extra_completions

  echo "Tools installed"
}

setup_extra_completions() {
  mkdir -p ${COMPL_DIR}

  # Download comletions
  for url in ${completion_urls}; do
    # :t keeps only the trailing path part
    # print -u2 prints to stderr
    curl --fail -o "${COMPL_DIR}${url:t}" ${url} || print -u2 "warn: Failed to download completions from ${url}"
  done

  # Generate completions
  if [[ -n $(command -v leaf) ]]; then
    leaf --auto-complete zsh:dump >"${COMPL_DIR}/_leaf" || print -u2 "warn: Failed to setup completions for leaf"
  fi

  if [[ -n $(command -v delta) ]]; then
    delta --generate-completion zsh >"${COMPL_DIR}/_delta" || print -u2 "warn: Failed to setup completions for delta"
  fi
}

apply() {
  for dotfile in ${DOTFILES}; do
    # Strip ':' and everything after it
    system_files="${dotfile%%:*}"
    # Strip everything up to and including ':'
    repo_files="${dotfile##*:}"
    copy_with_mkdir "${repo_files}" "${system_files}"
  done

  echo "Dotfiles applied"
}

show_help() {
  echo "Usage: ${script_name} ([-a] [-i]) | [-s] | [-h]"
  echo "  -i, --install   Install tools"
  echo "  -a, --apply      Apply dotfiles"
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

if [[ -n $help ]]; then
  show_help
  exit 0
fi

if [[ -n $save && (-n $apply || -n $install) ]]; then
  echo "--save option is incompatible with --apply and --install options"
  show_help
  exit 1
fi

if [[ -n $save ]]; then
  save
fi

if [[ -n $apply ]]; then
  apply
fi

if [[ -n $install ]]; then
  install
fi
