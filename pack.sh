#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p bin
out="bin/out.lua"

{
  printf '%s\n' '--[==[badge-app'
  awk '{print} END{print ""}' manifest.cfg
  printf '%s\n' ']==]'
  printf '%s\n' ''
  cat main.lua
} > "$out"

printf 'Wrote %s (%d bytes)\n' "$out" "$(wc -c < "$out" | tr -d ' ')"
