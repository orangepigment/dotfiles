#!/usr/bin/env nu

def main [] {
  zsh -ic 'bindkey -L; exit'
  | lines
  | parse --regex "(?<command>bindkey(?: -[a-zA-z]+)*) (?<binding>".+") (?<action>.+)"
  | save zsh_keybindings.nuon
}
