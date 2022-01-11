#!/bin/bash
# Simple RVM install script

set -e

user=$1
if [ -z "$user" ]; then
  echo "ERROR: User to install RVM for must be passed" >&2
  exit 1
fi

# Checking for already installed RVM
if ! type rvm 2>/dev/null 1>/dev/null ; then
  if ! which rvm 2>/dev/null 1>/dev/null ; then
    echo "Setting up RVM"
    which gpg 1>/dev/null 2>&1 && curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    which gpg 1>/dev/null 2>&1 && curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable --auto-dotfiles
  fi
fi
