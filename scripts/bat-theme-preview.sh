#!/usr/bin/env bash

set -euo pipefail

bat --list-themes | fzf --preview="bat --theme={} --color=always ${1}"
