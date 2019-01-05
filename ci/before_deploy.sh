#!/usr/bin/env bash
set -ex

. "$(dirname $0)/utils.sh"

build() {
  cargo build --target "$TARGET" --release
}

mk_tarball() {
  local tmpdir="$(mktemp -d -p .)"
  echo "tmpdir = $tmpdir"
  local name="gitall-${TRAVIS_TAG}"
  local staging="$tmpdir/$name"
  mkdir -p "$staging"/complete

  local out_dir="$(pwd)/deployment"
  mkdir -p "$out_dir"

  local cargo_out="$(cargo_out_dir "target/$TARGET")"

  cp "target/$TARGET/release/gitall" "$staging/gitall"
  strip "$staging/gitall"
  cp {CHANGELOG.md,COPYING,LICENSE-MIT,README.md,UNLICENSE} "$staging/"

  # copy shell completion files
  cp "$cargo_out"/gitall.{bash,elv,fish} "$cargo_out"/_gitall{,.ps1} "$staging/complete/"

  ( cd "$tmpdir" && tar czf "$out_dir/$name.tar.gz" "$name" )
  rm -rf "$tmpdir"
}

main() {
  build
  mk_tarball
}

main
