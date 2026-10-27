#!/usr/bin/env zsh

set -euo pipefail

colors=(red green yellow blue magenta cyan)

for c in $colors; do
  print -P "%F{$c}$c%f"
done
