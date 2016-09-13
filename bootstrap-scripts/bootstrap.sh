#!/bin/bash
# Shell script to bootstrap a developer workstation
# Inspired by solowizard.com
#
# Usage:
#   Running the script remotely:
#     bash < <(curl -s https://raw.github.com/trinitronx/sprout-wrap/spica-local-devbox/bootstrap-scripts/bootstrap.sh )
#   Running the script if you have downloaded it:
#     ./bootstrap.sh
#
# http://github.com/trinitronx/sprout-wrap
# (c) 2013, James Cuzella
# This script may be freely distributed under the MIT license.

## Figure out OSX version (source: https://www.opscode.com/chef/install.sh)
function detect_platform_version() {
  # Matching the tab-space with sed is error-prone
  platform_version=$(sw_vers | awk '/^ProductVersion:/ { print $2 }')

  major_version=$(echo $platform_version | cut -d. -f1,2)
  
  # x86_64 Apple hardware often runs 32-bit kernels (see OHAI-63)
  x86_64=$(sysctl -n hw.optional.x86_64)
  if [ $x86_64 -eq 1 ]; then
    machine="x86_64"
  fi
}

## Spawn sudo in background subshell to refresh the sudo timestamp
prevent_sudo_timeout() {
  # Note: Don't use GNU expect... just a subshell (for some reason expect spawn jacks up readline input)
  echo "Please enter your sudo password to make changes to your machine"
  sudo -v # Asks for passwords
  ( while true; do sudo -v; sleep 40; done ) &   # update the user's timestamp
  export sudo_loop_PID=$!
}

# Kill sudo timestamp refresh PID and invalidate sudo timestamp
kill_sudo_loop() {
  echo "Killing $sudo_loop_PID due to trap"
  kill -TERM $sudo_loop_PID
  sudo -K
}
trap kill_sudo_loop EXIT HUP TSTP QUIT SEGV TERM INT ABRT  # trap all common terminate signals
trap "exit" INT # Run exit when this script receives Ctrl-C


SOLOIST_DIR="${HOME}/src/pub/soloist"
#XCODE_DMG='XCode-4.6.3-4H1503.dmg'
SPROUT_WRAP_URL='https://github.com/trinitronx/sprout-wrap.git'
SPROUT_WRAP_BRANCH='spica-local-devbox'

detect_platform_version

# Determine which XCode version to use based on platform version
case $platform_version in
  10.11*) XCODE_DMG='Xcode_7.3.1.dmg' ;;
  10.10*) XCODE_DMG='Xcode_6.3.2.dmg' ;;
  "10.9") XCODE_DMG='XCode-5.0.2-5A3005.dmg' ;;
  *)      XCODE_DMG='XCode-5.0.1-5A2053.dmg' ;;

esac

errorout() {
  echo -e "\x1b[31;1mERROR:\x1b[0m ${1}"; exit 1
}

pushd `pwd`

# Bootstrap XCode from dmg
if [ ! -d "/Applications/Xcode.app" ]; then
  echo "INFO: XCode.app not found. Installing XCode..."
  if [ ! -e "$XCODE_DMG" ]; then
    curl -L -O "http://lyraphase.com/installers/mac/${XCODE_DMG}" || curl -L -O "http://adcdownload.apple.com/Developer_Tools/${XCODE_DMG%%.dmg}/${XCODE_DMG}"
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
  git clone $SPROUT_WRAP_URL
  pushd sprout-wrap
  git checkout $SPROUT_WRAP_BRANCH
fi

# Hack to make sure sudo caches sudo password correctly...
# And so it stays available for the duration of the Chef run
prevent_sudo_timeout
readonly sudo_loop_PID  # Make PID readonly for security ;-)


curl -Ls https://gist.github.com/trinitronx/6217746/raw/dc456e5c316c716f4685de20471ae8301a87c434/xcode-cli-tools.sh | sudo bash

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

popd; popd

exit
