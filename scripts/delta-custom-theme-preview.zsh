#!/usr/bin/env zsh

set -euo pipefail

themes_str=$(bat ~/.config/delta/themes.gitconfig | rg "\[delta .+\]" | sd '[\[\"\]]' '' | hck -f 2)

for theme in ${(f)themes_str}; do
  echo $theme
  DELTA_FEATURES=${theme} git show HEAD^ | delta
done
