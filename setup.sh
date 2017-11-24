#!/bin/bash
#
# foax/dotfiles/setup.sh
# ======================
#
# Perform initial setup for dotfiles.

set -e

dotfile_basedir=$(cd $(dirname $0); pwd)

# I would use an associative array here, but this is only supported by
# bash version 4+. So normal arrays it is.

dotfiles=(oh-my-zsh zshrc zshenv)

echoerr() {
  echo "$@" 1>&2
}

errexit() {
  echoerr "ERROR: $1"
  exit $2
}

# Compute relative path between two absolute paths
# https://unix.stackexchange.com/a/269303

relpath() {
  local pos="${1%%/}" ref="${2%%/}" down=''

  while :; do
    test "$pos" = '/' && break
    case "$ref" in $pos/*) break;; esac
    down="../$down"
    pos=${pos%/*}
  done

  echo "$down${ref##$pos/}"
}

for target in "${dotfiles[@]}"; do
  file=".${target}"
  abs_file="$HOME/$file"
  abs_target="$dotfile_basedir/$target"

  if [[ -e $abs_file ]]; then

    # Check if a symlink already exists to dotfile target
    if [[ -L $abs_file ]]; then
      symlink_inode=$(stat -L -f %i "$abs_file")
      target_inode=$(stat -L -f %i "$abs_target")
      if [[ $symlink_inode == $target_inode ]]; then
        continue
      fi
    fi
    echo "Dot file $file already exists. Remove this file and try again afterwards."

  else
    echo "Setting up symlink $file -> $target"
    rel_target="$(relpath "$HOME" "$abs_target")"
    ln -s $rel_target $abs_file
  fi

done
