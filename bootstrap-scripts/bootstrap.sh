#!/bin/bash
# Shell script to bootstrap a developer workstation
# Inspired by solowizard.com
#
# Usage:
#   Running the script remotely:
#     bash < <(curl -s https://raw.github.com/TangoGroup/sprout-wrap/gloo-develop/bootstrap-scripts/bootstrap.sh )
#   Running the script if you have downloaded it:
#     ./bootstrap.sh
#
# http://github.com/TangoGroup/sprout-wrap
# (c) 2012, Tom Hallett
# This script may be freely distributed under the MIT license.

SOLOIST_DIR="${HOME}/src/pub/soloist/"
XCODE_DMG='XCode-4.6.3-4H1503.dmg'

pushd `pwd`

# Bootstrap XCode from dmg
if [ ! -d "/Applications/Xcode.app" ]; then
  [ -e "$XCODE_DMG" ] || curl -L -O "http://gloo.ops.s3.amazonaws.com/${XCODE_DMG}"
  hdiutil attach "$XCODE_DMG"
  export __CFPREFERENCES_AVOID_DAEMON=1
  sudo installer -pkg '/Volumes/XCode/XCode.pkg' -target /
  hdiutil detach '/Volumes/XCode'
fi

mkdir -p "$SOLOIST_DIR"; cd "$SOLOIST_DIR"

if [ -d sprout-wrap ]; then
  pushd sprout-wrap && git pull
else
  git clone https://github.com/TangoGroup/sprout-wrap.git
  pushd sprout-wrap
fi

# We need to accept the xcodebuild license agreement before building anything works
# Evil Apple...
if [ -x "$(which expect)" ]; then
  expect ./bootstrap-scripts/accept-xcodebuild-license.exp
else
  echo -e "\x1b[31;1mERROR:\x1b[0m Could not find expect utility (is '$(which expect)' executable?)"
  echo -e "\x1b[31;1mWarning:\x1b[0m You have not agreed to the Xcode license.\nBuilds will fail! Agree to the license by opening Xcode.app or running:\n
    xcodebuild -license\n\nOR for system-wide acceptance\n
    sudo xcodebuild -license"
  exit 1
fi

if rvm --version 2>/dev/null; then
  gem install bundler
else
  sudo gem install bundler
fi

bundle install --without development

soloist

popd
popd