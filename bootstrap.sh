#!/bin/bash
# Shell script to bootstrap a developer workstation
# Inspired by solowizard.com
#
# Usage:
#   Running the script remotely:
#     bash < <(curl -s https://raw.github.com/TangoGroup/sprout-wrap/gloo-develop/bootstrap.sh )
#   Running the script if you have downloaded it:
#     ./bootstrap.sh
#
# http://github.com/TangoGroup/sprout-wrap
# (c) 2012, Tom Hallett
# This script may be freely distributed under the MIT license.

SOLOIST_DIR='~/src/pub/soloist/'

pushd `pwd`
if rvm --version 2>/dev/null; then
  gem install soloist
else
  sudo gem install soloist
fi

mkdir -p "$SOLOIST_DIR"; cd "$SOLOIST_DIR"

if [[ -d sprout-wrap ]]; then
  cd sprout-wrap && git pull && cd ..
else
  git clone https://github.com/TangoGroup/sprout-wrap.git
fi

soloist
popd
