#!/usr/bin/env zsh

set -euo pipefail

delta --list-syntax-themes | hck -D ' ' -f 2- | fzf --preview="git show HEAD^ | delta --true-color never --syntax-theme={}"

