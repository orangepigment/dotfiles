#!/usr/bin/env nu

def main [] {
  hx --health
  | lines
  | skip 8 # Drop technical info
  | split column --regex '\s{2,}'
  | headers
  | drop column 1 # Drop trailing empty column
  | save -f helix_health.nuon
}
