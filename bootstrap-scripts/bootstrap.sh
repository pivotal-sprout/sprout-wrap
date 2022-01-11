#!/bin/bash
# Shell script to bootstrap a developer workstation
# Inspired by solowizard.com
#
# Usage:
#   Running the script remotely:
#     bash < <(curl -s https://raw.github.com/LyraPhase/sprout-wrap/master/bootstrap-scripts/bootstrap.sh )
#   Running the script if you have downloaded it:
#     ./bootstrap.sh
#
# http://github.com/LyraPhase/sprout-wrap
# Copyright (C) © 🄯  2013-2021 James Cuzella
# This script may be freely distributed under the MIT license.

## Figure out OSX version (source: https://www.opscode.com/chef/install.sh)
function detect_platform_version() {
  # Matching the tab-space with sed is error-prone
  platform_version=$(sw_vers | awk '/^ProductVersion:/ { print $2 }')

  major_version=$(echo "$platform_version" | cut -d. -f1,2)

  # x86_64 Apple hardware often runs 32-bit kernels (see OHAI-63)
  # macOS Monterey + Apple M1 Silicon (arm64) gives empty string for this x86_64 check
  x86_64=$(sysctl -n hw.optional.x86_64)
  arm64=$(sysctl -n hw.optional.arm64)
  if [[ "$x86_64" == '1' ]]; then
    machine="x86_64"
  elif [[ "$arm64" == '1' ]]; then
    machine="arm64"
  fi
}

## Spawn sudo in background subshell to refresh the sudo timestamp
prevent_sudo_timeout() {
  # Note: Don't use GNU expect... just a subshell (for some reason expect spawn jacks up readline input)
  echo "Please enter your sudo password to make changes to your machine"
  sudo -v # Asks for passwords
  ( while true; do sudo -v; sleep 40; done ) &   # update the user's timestamp
  export timeout_loop_PID=$!
}

# Kill sudo timestamp refresh PID and invalidate sudo timestamp
kill_timeout_loop() {
  echo "Killing $timeout_loop_PID due to trap"
  kill -TERM $timeout_loop_PID
  sudo -K
}
trap kill_timeout_loop EXIT HUP TSTP QUIT SEGV TERM INT ABRT  # trap all common terminate signals
trap "exit" INT # Run exit when this script receives Ctrl-C

## Drop-In replacement for prevent_sudo_timeout in CI
## CI has sudo, but long-running jobs can timeout
## unless log output is frequent enough
prevent_ci_log_timeout() {
  echo "INFO: CI run detected via \$CI=$CI env var"
  echo "INFO: Starting log timeout prevention process..."
  ( while true; do echo '.'; sleep 40; done ) &   # update STDOUT logs
  export timeout_loop_PID=$!
}

function check_trace_state() {
  if shopt -op 2>&1 | grep -q xtrace; then
    trace_was_on=1
  else
    trace_was_on=0
  fi
}

function init_trace_on() {
  PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' ## Debugging prompt (for bash -x || set -x)
  set -x
}

function turn_trace_on_if_was_on() {
  [ $trace_was_on -eq 1 ] && set -x ## Turn trace back on
}

function turn_trace_off() {
  set +x ## RVM trace is NOISY!
}

function check_sprout_locked_ruby_versions() {
  # Check locked versions
  sprout_ruby_version=$(cat "${REPO_BASE}/.ruby-version" | tr -d '\n')
  sprout_ruby_gemset=$(cat "${REPO_BASE}/.ruby-gemset" | tr -d '\n')
  sprout_rubygems_ver=$(cat "${REPO_BASE}/.rubygems-version" | tr -d '\n') ## Passed to gem update --system
  sprout_bundler_ver=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | tr -d '[:blank:]')
}

function rvm_set_compile_opts() {
  turn_trace_on_if_was_on
  if [[ "$RVM_COMPILE_OPTS_M1_LIBFFI" == "1" ]]; then
    export optflags="-Wno-error=implicit-function-declaration"
    export LDFLAGS="-L/opt/homebrew/opt/libffi/lib"
    export DLDFLAGS="-L/opt/homebrew/opt/libffi/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/libffi/include"
    export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig"
    bundle config build.ffi --enable-system-libffi
  fi

  if [[ "$RVM_COMPILE_OPTS_M1_NOKOGIRI" == "1" ]]; then
    bundle config build.nokogiri --platform=ruby -- --use-system-libraries
  fi
  turn_trace_off
}

function brew_install_rvm_libs() {
  if [[ "$BREW_INSTALL_LIBFFI" == "1" ]]; then
    grep -q 'libffi' Brewfile || echo "brew 'libffi'" >> Brewfile
  fi
  if [[ "$BREW_INSTALL_NOKOGIRI_LIBS" == "1" ]]; then
    grep -q 'libxml2' Brewfile || echo "brew 'libxml2'" >> Brewfile
    grep -q 'libxslt' Brewfile || echo "brew 'libxslt'" >> Brewfile
    grep -q 'libiconv' Brewfile || echo "brew 'libiconv'" >> Brewfile
  fi
}

function rvm_install_ruby_and_gemset() {
  check_sprout_locked_ruby_versions

  rvm_set_compile_opts

  rvm install "ruby-${sprout_ruby_version}"
  rvm use "ruby-${sprout_ruby_version}"
  rvm gemset create "$sprout_ruby_gemset"
  rvm use "ruby-${sprout_ruby_version}"@"${sprout_ruby_gemset}"
}

function rvm_install_bundler() {
  check_sprout_locked_ruby_versions

  # Install bundler + rubygems in RVM path
  echo rvm "${sprout_ruby_version}" do gem update --system "${sprout_rubygems_ver}"
  rvm "${sprout_ruby_version}" do gem update --system "${sprout_rubygems_ver}"

  # Install same version of bundler as Gemfile.lock
  echo rvm "${sprout_ruby_version}" do gem install --default bundler:"${sprout_bundler_ver}"
  rvm "${sprout_ruby_version}" do gem install --default "bundler:${sprout_bundler_ver}"
}

function rvm_debug_gems() {
  if [ "$trace_was_on" -eq 1 ]; then
    echo "======= DEBUG ============"
    type rvm | head -1
    which ruby
    which bundler
    rvm info
    echo "GEMS IN SHELL ENV:"
    gem list
    echo "GEMS IN ${sprout_ruby_version}@${sprout_ruby_gemset}:"
    rvm "${sprout_ruby_version}"@"${sprout_ruby_gemset}" do gem list
    echo "======= DEBUG ============"
  fi
}

if [[ "$SOLOIST_DEBUG" == 'true' ]]; then
  init_trace_on
fi

# CI setup
if [[ "$CI" == 'true' ]]; then
  init_trace_on
  SOLOIST_DIR="${GITHUB_WORKSPACE}/.."
  SPROUT_WRAP_BRANCH="$GITHUB_REF_NAME"
fi

use_system_ruby=0
SOLOISTRC=${SOLOISTRC:-soloistrc}
SOLOIST_DIR=${SOLOIST_DIR:-"${HOME}/src/pub/soloist"}
#XCODE_DMG='XCode-4.6.3-4H1503.dmg'
SPROUT_WRAP_URL='https://github.com/LyraPhase/sprout-wrap.git'
SPROUT_WRAP_BRANCH=${SPROUT_WRAP_BRANCH:-'master'}
HOMEBREW_INSTALLER_URL='https://raw.githubusercontent.com/Homebrew/install/master/install.sh'
USER_AGENT="Chef Bootstrap/$(git rev-parse HEAD) ($(curl --version | head -n1); $(uname -m)-$(uname -s | tr 'A-Z' 'a-z')$(uname -r); +https://lyraphase.com)"

if [[ "${BASH_SOURCE[0]}" != '' ]]; then
  # Running from checked out script
  REPO_BASE=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
else
  # Running via curl | bash (piped)
  REPO_BASE=${SOLOIST_DIR}/sprout-wrap
fi

detect_platform_version

# Determine which XCode version to use based on platform version
# https://developer.apple.com/downloads/index.action
case $platform_version in
  12.0*|12.1*)
          XCODE_DMG='Xcode_13.2.xip'; export TRY_XCI_OSASCRIPT_FIRST=1; BREW_INSTALL_LIBFFI=1; RVM_COMPILE_OPTS_M1_LIBFFI=1 ;
          BREW_INSTALL_NOKOGIRI_LIBS="1" ; RVM_COMPILE_OPTS_M1_NOKOGIRI=1 ;;
  11.6*)  XCODE_DMG='Xcode_13.1.xip'; export TRY_XCI_OSASCRIPT_FIRST=1; export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ;;
  10.15*) XCODE_DMG='Xcode_12.4.xip'; export INSTALL_SDK_HEADERS=1 ; export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ;;
  10.14*) XCODE_DMG='Xcode_11_GM_Seed.xip'; export INSTALL_SDK_HEADERS=1 ; export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES ;;
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

# TODO: Figure out if Xcodes CLI tool will work?
#       https://github.com/RobotsAndPencils/Xcodes
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

    if [[ -x "$(which xip)" ]]; then
      xip -x "${REPO_BASE}/${XCODE_DMG}"
      sudo mv ./Xcode.app /Applications/
    else
      xar -C "${TMP_DIR}/" -xf "$XCODE_DMG"
      pushd "$TMP_DIR"
      curl -O https://gist.githubusercontent.com/pudquick/ff412bcb29c9c1fa4b8d/raw/24b25538ea8df8d0634a2a6189aa581ccc6a5b4b/parse_pbzx2.py
      python parse_pbzx2.py Content
      xz -d Content.part*.cpio.xz
      sudo /bin/sh -c 'cat ./Content.part*.cpio' | sudo cpio -idm
      sudo mv ./Xcode.app /Applications/
      popd
    fi
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
if [[ "$CI" == 'true' ]]; then
  set +x
  prevent_ci_log_timeout
  set -x
else
  prevent_sudo_timeout
fi
readonly timeout_loop_PID  # Make PID readonly for security ;-)

# Try xcode-select --install first
if [[ "$TRY_XCI_OSASCRIPT_FIRST" == '1' ]]; then
  # Try the AppleScript automation method rather than relying on manual .xip / .dmg download & mirroring
  # Note: Apple broke automated Xcode installer downloads.  Now requires manual Apple ID sign-in.
  # Source: https://web.archive.org/web/20211210020829/https://techviewleo.com/install-xcode-command-line-tools-macos/
  if [ ! -d /Library/Developer/CommandLineTools ]; then
    xcode-select --install
    sleep 1
    osascript <<-EOD
  	  tell application "System Events"
  	    tell process "Install Command Line Developer Tools"
  	      keystroke return
  	      click button "Agree" of window "License Agreement"
  	    end tell
  	  end tell
EOD
  else
    echo "INFO: Found /Library/Developer/CommandLineTools already existing. skipping..."
  fi
else
	# !! This script is no longer supported !!
	#  Apple broke all direct downloads without logging with an Apple ID first.
	#   The number of hoops that a script would need to jump through to login,
	#   store cookies, and download is prohibitive.
	#   Now we all must manually download and mirror the files for this to work at all :'-(
	curl -Ls https://gist.githubusercontent.com/trinitronx/6217746/raw/d0c12be945f1984fc7c40501f5235ff4b93e71d6/xcode-cli-tools.sh | sudo bash
fi

# We need to accept the xcodebuild license agreement before building anything works
# Evil Apple...
if [ -x "$(which expect)" ]; then
  echo "INFO: GNU expect found! By using this script, you automatically accept the XCode License agreement found here: http://www.apple.com/legal/sla/docs/xcode.pdf"
  # Git.io short URL to: ./bootstrap-scripts/accept-xcodebuild-license.exp
  #curl -Ls 'https://git.io/viaLD' | sudo expect -
  sudo expect "${REPO_BASE}/bootstrap-scripts/accept-xcodebuild-license.exp"
else
  echo -e "\x1b[31;1mERROR:\x1b[0m Could not find expect utility (is '$(which expect)' executable?)"
  echo -e "\x1b[31;1mWarning:\x1b[0m You have not agreed to the Xcode license.\nBuilds will fail! Agree to the license by opening Xcode.app or running:\n
    xcodebuild -license\n\nOR for system-wide acceptance\n
    sudo xcodebuild -license"
  exit 1
fi


if [[ "$INSTALL_SDK_HEADERS" == '1' ]]; then
  # Reference: https://github.com/Homebrew/homebrew-core/issues/18533#issuecomment-332501316
  if ruby_mkmf_output="$(ruby -r mkmf -e 'print $hdrdir + "\n"')" && [ -d "$ruby_mkmf_output" ];
  then
     echo "INFO: Ruby header files successfully found!"
  else
    # This requires user interaction... but Mojave XCode CLT is broken!
    # Reference: https://donatstudios.com/MojaveMissingHeaderFiles
    sudo rm -rf /Library/Developer/CommandLineTools
    sudo xcode-select --install
    xcode_clt_pid=$(ps auxww | grep -i 'Install Command Line Developer Tools' | grep -v grep | awk '{ print $2 }')
    # wait for non-child PID of CLT installer dialog UI
    while ps -p "$xcode_clt_pid" >/dev/null ; do sleep 1; done

    sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg  -target /
  fi
fi

brew_install_rvm_libs

if [[ "$CI" == 'true' ]]; then
  echo "INFO: CI run detected via \$CI=$CI env var"
  echo "INFO: NOT checking out git repo"
  echo "INFO: Running soloist from ${REPO_BASE}/test/fixtures"
  # Must use pushd to keep dir stack 2 items deep
  pushd "${REPO_BASE}/test/fixtures"
else
  # Checkout sprout-wrap after XCode CLI tools, because we need it for git now
  mkdir -p "$SOLOIST_DIR"; cd "$SOLOIST_DIR/"

  echo "INFO: Checking out sprout-wrap..."
  if [ -d sprout-wrap ]; then
    pushd sprout-wrap && git pull
  else
    git clone "$SPROUT_WRAP_URL"
    pushd sprout-wrap
    git checkout "$SPROUT_WRAP_BRANCH"
  fi
fi

# Non-Chef Homebrew install
check_trace_state
turn_trace_off
brew --version
[ -x "$(which brew)" -a "$?" -eq 0 ] || echo | /bin/bash -c "$(curl -fsSL "$HOMEBREW_INSTALLER_URL" )"
turn_trace_on_if_was_on

if [ "$machine" == "arm64" ]; then
  export PATH="/opt/homebrew/bin:${PATH}"
else
  export PATH="/usr/local/homebrew/bin:${PATH}"
fi


# Install Chef Workstation SDK via Brewfile
[ -x "$(which brew)" ] && brew bundle install

if [[ $use_system_ruby == "1" ]]; then
  # We should never get here unless script has been edited by hand
  # User probably knows what they're doing but warn anyway
  echo "WARN: Using macOS system Ruby is not recommended!" >&2
  echo "WARN: Updating system bundler gem will modify stock macOS system files!" >&2
  if [[ "$override_use_system_ruby_prompt" != '1' ]]; then
    read -p 'Are you sure you want to continue and use macOS System Ruby? [y/N]: ' -d $'\n' use_system_ruby_answer
    use_system_ruby_answer="$(echo -n "$use_system_ruby_answer" | tr 'A-Z' 'a-z')"
    if [[ "$use_system_ruby_answer" != 'y' ]]; then
      errorout "Abort modifying System Ruby! Exiting..."
    else
      USE_SUDO='sudo'
    fi
  fi

  echo "INFO: Updating system bundler gem!" >&2
  [ -x "/usr/local/bin/bundle" ] || $USE_SUDO gem install -n /usr/local/bin bundler
  $USE_SUDO gem update -n /usr/local/bin --system

elif [[ "$CI" != 'true' ]]; then
  USE_SUDO=''
  export rvm_user_install_flag=1
  export rvm_prefix="$HOME"
  export rvm_path="${rvm_prefix}/.rvm"

  echo "Installing RVM..." >&2

  bash -c "${REPO_BASE}/bootstrap-scripts/bootstrap-rvm.sh $USER"

  # RVM trace is NOISY!
  check_trace_state
  turn_trace_off

  if ! type rvm 2>&1 | grep -q 'rvm is a function' ; then
    # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
    export PATH="$PATH:$HOME/.rvm/bin"

    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
  fi

  # Install .ruby-version @ .ruby-gemset
  rvm_install_ruby_and_gemset

  rvm_install_bundler

  rvm_debug_gems

  turn_trace_on_if_was_on

else
  # Just update bundler in CI
  gem update --system
fi

# We need bundler in vendor path too
check_sprout_locked_ruby_versions
if ! bundle list | grep -q "bundler.*${sprout_bundler_ver}"; then
  bundle exec gem install --default "bundler:${sprout_bundler_ver}"
fi


# TODO: Fix last chicken-egg issues
echo "WARN: Please set up github SSH / HTTPS credentials for Chef Homebrew recipes to work!"

# Bundle install soloist + gems
if ! bundle check >/dev/null 2>&1; then
  bundle config set --local path 'vendor/bundle' ;
  bundle config set --local without 'development' ;
  # --path & --without have deprecation warnings... but for now we'll try them
  bundle install --path vendor/bundle --without development ;
fi

if [[ -n "$SOLOISTRC" && "$SOLOISTRC" != 'soloistrc' ]]; then
  echo "INFO: Custom $SOLOISTRC passed: $SOLOISTRC"
  if [[ -f "$SOLOISTRC" && "$(readlink soloistrc)" != "$SOLOISTRC" ]]; then
    echo "WARN: default soloistrc file is NOT symlinked to $SOLOISTRC"
    echo "WARN: Forcing re-link: soloistrc -> $SOLOISTRC"
    ln -sf "$SOLOISTRC" soloistrc
  fi
fi

# Auto-accept Chef license for non-interactive automation
export CHEF_LICENSE=accept
# Now we provision with chef, et voilá!
# Node, it's time you grew up to who you want to be
caffeinate -dimsu bundle exec soloist || errorout "Soloist provisioning failed!"

turn_trace_off ## RVM noisy on builtin: popd
popd; popd

exit
