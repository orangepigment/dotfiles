#!/usr/bin/env nu

let keys = {
  F1: '^[OP'
  F2: '^[OQ'
  F3: '^[OR'
  F4: '^[OS'
  F5: '^[[15~'
  F6: '^[[17~'
  F7: '^[[18~'
  F8: '^[[19~'
  F9: '^[[20~'
  F10: '^[[21~'
  F11: '^[[23~'
  F12: '^[[24~'
  Backspace: '^?'
  Insert: '^[[2~'
  Home: '^[[H'
  PageUp: '^[[5~'
  Delete: '^[[3~'
  End: '^[[F'
  PageDown: '^[[6~'
  Up: '^[[A'
  Left: '^[[D'
  Down: '^[[B'
  Right: '^[[C'
} | transpose key raw_key

let tmp_dump = 'raw_dump.tmp'

def replace_keys [binding: string] {
  $keys
  | reduce --fold $binding {|it, acc| $acc | str replace $it.raw_key $it.key }
  | str replace '^[' 'Alt+'
  | str replace '^' 'Ctrl+'
}

def main [] {
  # Dump to a file as a workaround to broken pipe problem
  zsh -ic $"bindkey -L >($tmp_dump); exit"

  open $tmp_dump
  | lines
  | each {replace_keys $in}
  | parse --regex "(?<command>bindkey(?: -[a-zA-z]+)*) (?<binding>".+") (?<action>.+)"
  | save -f zsh_keybindings.nuon

  rm $tmp_dump
}
