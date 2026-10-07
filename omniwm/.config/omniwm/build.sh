#!/bin/sh

set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
target="$HOME/.config/omniwm/settings.toml"
tmp=$(mktemp "${target}.tmp.XXXXXX")

cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT HUP INT TERM

for module in "$root"/modules/*.toml; do
  [ -f "$module" ] || continue
  cat "$module" >> "$tmp"
  printf '\n' >> "$tmp"
done

[ -s "$tmp" ] || {
  echo "No OmniWM modules found." >&2
  exit 1
}

mv "$tmp" "$target"
trap - EXIT HUP INT TERM
echo "Rendered $target"
