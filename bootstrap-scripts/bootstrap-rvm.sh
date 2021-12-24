#!/bin/bash
# Simple RVM install script

set -e

function add_rvm_to_profile() {
  shell_profile="$1"
  echo "INFO: Adding RVM sourcing line to ${shell_profile}"
  tee -a "${shell_profile}" > /dev/null <<RVMSH_CONTENT
[[ -s "\${HOME}/.rvm/scripts/rvm" ]] && source "\${HOME}/.rvm/scripts/rvm"
RVMSH_CONTENT
  chmod +x "${shell_profile}"
}


user=$1
if [ -z "$user" ]; then
  echo "ERROR: User to install RVM for must be passed" >&2
  exit 1
fi

# Checking for already installed RVM
if ! type rvm 2>/dev/null 1>/dev/null ; then
  if ! which rvm 2>/dev/null 1>/dev/null ; then
    echo "Setting up RVM"
    which gpg 2>&1 1>/dev/null && curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    which gpg 2>&1 1>/dev/null && curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable
  fi

  user_home="$(eval echo ~${user})"

  # If no .zprofile or .bash_profile found... use default .profile
  add_to_default_profile=1
  for shell_profile in "${user_home}/.zprofile" "${user_home}/.bash_profile" ; do
    if [ -e "${shell_profile}" ] && ! grep -Eq '^source.*scripts/rvm' "$shell_profile"; then
      add_rvm_to_profile "$shell_profile"
      add_to_default_profile=0
    fi
  done
  if [ $add_to_default_profile -eq 1 ]; then
      add_rvm_to_profile "${user_home}/.profile"
  fi
fi
