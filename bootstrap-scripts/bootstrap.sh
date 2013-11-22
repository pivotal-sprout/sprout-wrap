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

SOLOIST_DIR="${HOME}/src/pub/soloist"
BRANCH="${1:-master}"

if [[ "$BRANCH" == mavericks* ]]; then
  XCODE_DMG='XCode-5.0.1-5A2053.dmg'
else
  XCODE_DMG='XCode-4.6.3-4H1503.dmg'
fi

errorout() {
  echo -e "\x1b[31;1mERROR:\x1b[0m ${1}"; exit 1
}

pushd `pwd`

# Bootstrap XCode from dmg
if [ ! -d "/Applications/Xcode.app" ]; then
  echo "INFO: XCode.app not found. Installing XCode..."
  if [ ! -e "$XCODE_DMG" ]; then
    curl -L -O "http://bro-fs-01.bro.gloostate.com/installers/mac/${XCODE_DMG}" || curl -L -O "http://gloo.ops.s3.amazonaws.com/${XCODE_DMG}"
  fi
    
  hdiutil attach "$XCODE_DMG"
  export __CFPREFERENCES_AVOID_DAEMON=1
  sudo installer -pkg '/Volumes/XCode/XCode.pkg' -target /
  hdiutil detach '/Volumes/XCode'
fi

mkdir -p "$SOLOIST_DIR"; cd "$SOLOIST_DIR/"

echo "INFO: Checking out sprout-wrap..."
if [ -d sprout-wrap ]; then
  pushd sprout-wrap && git pull
else
  git clone https://github.com/TangoGroup/sprout-wrap.git
  pushd sprout-wrap
  [ -n "$BRANCH" ] && git checkout $BRANCH && git pull
fi

# Hack to make sure sudo caches sudo password correctly...
# (for some reason expect spawn jacks up readline input)
echo "Please enter your sudo password to make changes to your machine"
sudo echo ''

curl -Ls https://gist.github.com/trinitronx/6217746/raw/58456d6675e437cebbf771c60b6005b4491a0980/xcode-cli-tools.sh | sudo bash

# We need to accept the xcodebuild license agreement before building anything works
# Evil Apple...
if [ -x "$(which expect)" ]; then
  echo "INFO: GNU expect found! By using this script, you automatically accept the XCode License agreement found here: http://www.apple.com/legal/sla/docs/xcode.pdf"
  expect ./bootstrap-scripts/accept-xcodebuild-license.exp
else
  echo -e "\x1b[31;1mERROR:\x1b[0m Could not find expect utility (is '$(which expect)' executable?)"
  echo -e "\x1b[31;1mWarning:\x1b[0m You have not agreed to the Xcode license.\nBuilds will fail! Agree to the license by opening Xcode.app or running:\n
    xcodebuild -license\n\nOR for system-wide acceptance\n
    sudo xcodebuild -license"
  exit 1
fi


rvm --version 2>/dev/null
[ ! -x "$(which gem)" -a "$?" -eq 0 ] || USE_SUDO='sudo'

$USE_SUDO gem install bundler
if ! bundle check 2>&1 >/dev/null; then $USE_SUDO bundle install --without development ; fi

export rvm_user_install_flag=1
export rvm_prefix="$HOME"
export rvm_path="${rvm_prefix}/.rvm"

# Now we provision with chef, et voilá!
# Node, it's time you grew up to who you want to be
soloist || errorout "Soloist provisioning failed!"

popd

if [ -d "${HOME}/src/gloo/gloo-chef" ]; then
  . ~/.rvm/scripts/rvm
  pushd "${HOME}/src/gloo/gloo-chef"
  bash ./update.sh
  vagrant plugin install vagrant-berkshelf
fi

popd; popd
