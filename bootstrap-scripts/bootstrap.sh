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
# (c) 2013-2017, James Cuzella
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
USER_AGENT="Chef Bootstrap/$(git rev-parse HEAD) ($(curl --version | head -n1); $(uname -m)-$(uname -s | tr 'A-Z' 'a-z')$(uname -r); +https://lyraphase.com)"

detect_platform_version

# Determine which XCode version to use based on platform version
case $platform_version in
  10.14*) XCODE_DMG='Xcode_11_GM_Seed.xip' ;;
  10.12*) XCODE_DMG='Xcode_8.1.xip' ;;
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
    if [[ "$XCODE_DMG" =~ ^.*\.dmg$ ]]; then
      curl --fail --user-agent "$USER_AGENT" -L -O "http://lyraphase.com/doc/installers/mac/${XCODE_DMG}" || curl --fail -L -O "http://adcdownload.apple.com/Developer_Tools/${XCODE_DMG%%.xip}/${XCODE_DMG}"
    else
      curl --fail --user-agent "$USER_AGENT" -L -O "http://lyraphase.com/doc/installers/mac/${XCODE_DMG}" || curl --fail -L -O "http://adcdownload.apple.com/Developer_Tools/${XCODE_DMG%%.dmg}/${XCODE_DMG}"
    fi
  fi
    
  # Why does Apple have to make everything more difficult?
  if [[ "$XCODE_DMG" =~ ^.*\.xip$ ]]; then
    pkgutil --check-signature $XCODE_DMG
    TMP_DIR=$(mktemp -d /tmp/xcode-installer.XXXXXXXXXX)
    xar -C ${TMP_DIR}/ -xf $XCODE_DMG
    pushd $TMP_DIR
    curl -O https://gist.githubusercontent.com/pudquick/ff412bcb29c9c1fa4b8d/raw/24b25538ea8df8d0634a2a6189aa581ccc6a5b4b/parse_pbzx2.py
    python parse_pbzx2.py Content
    xz -d Content.part*.cpio.xz
    sudo cpio -idm < ./Content.part*.cpio
    sudo mv ./Xcode.app /Applications/
    popd
    [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR/"
  else
    hdiutil attach "$XCODE_DMG"
    export __CFPREFERENCES_AVOID_DAEMON=1
    if [ -e '/Volumes/XCode/XCode.pkg' ]; then
      sudo installer -pkg '/Volumes/XCode/XCode.pkg' -target /
    elif [ -e '/Volumes/XCode.app' ]; then
      sudo cp -r '/Volumes/XCode.app' '/Applications/'
    fi
    hdiutil detach '/Volumes/XCode'
  fi
fi



# Hack to make sure sudo caches sudo password correctly...
# And so it stays available for the duration of the Chef run
prevent_sudo_timeout
readonly sudo_loop_PID  # Make PID readonly for security ;-)


curl -Ls https://gist.githubusercontent.com/trinitronx/6217746/raw/d6dfe10a3fcf8397735d5421cc739affbe7d1e3c/xcode-cli-tools.sh | sudo bash

# We need to accept the xcodebuild license agreement before building anything works
# Evil Apple...
if [ -x "$(which expect)" ]; then
  echo "INFO: GNU expect found! By using this script, you automatically accept the XCode License agreement found here: http://www.apple.com/legal/sla/docs/xcode.pdf"
  # Git.io short URL to: ./bootstrap-scripts/accept-xcodebuild-license.exp
  curl -Ls 'https://git.io/viaLD' | expect -
else
  echo -e "\x1b[31;1mERROR:\x1b[0m Could not find expect utility (is '$(which expect)' executable?)"
  echo -e "\x1b[31;1mWarning:\x1b[0m You have not agreed to the Xcode license.\nBuilds will fail! Agree to the license by opening Xcode.app or running:\n
    xcodebuild -license\n\nOR for system-wide acceptance\n
    sudo xcodebuild -license"
  exit 1
fi

# Checkout sprout-wrap after XCode CLI tools, because we need it for git now
mkdir -p "$SOLOIST_DIR"; cd "$SOLOIST_DIR/"

echo "INFO: Checking out sprout-wrap..."
if [ -d sprout-wrap ]; then
  pushd sprout-wrap && git pull
else
  git clone $SPROUT_WRAP_URL
  pushd sprout-wrap
  git checkout $SPROUT_WRAP_BRANCH
fi

rvm --version 2>/dev/null
[ ! -x "$(which gem)" -a "$?" -eq 0 ] || USE_SUDO='sudo'

$USE_SUDO gem install bundler
$USE_SUDO gem update --system
if ! bundle check 2>&1 >/dev/null; then $USE_SUDO bundle install --without development ; fi

export rvm_user_install_flag=1
export rvm_prefix="$HOME"
export rvm_path="${rvm_prefix}/.rvm"

# Now we provision with chef, et voilá!
# Node, it's time you grew up to who you want to be
soloist || errorout "Soloist provisioning failed!"

popd; popd

exit
