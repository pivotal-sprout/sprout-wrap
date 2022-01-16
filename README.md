<!-- markdownlint-configure-file
{
  "required-headings": {
    "headings": [
      "# sprout-wrap",
      "*",
      "# NOTE: This is a Fork 🍴⚠️ 🔱",
      "*",
      "## Sponsor",
      "*",
      "## Prerequisites",
      "*",
      "## Installation on macOS",
      "### The Easy Way 🚀",
      "#### 1. Run bootstrap script",
      "### The Semi-Manual Way 💪",
      "#### 1. Install Command Line Tools",
      "#### Installation",
      "*",
      "#### 2. Ruby Installation",
      "##### Install RVM",
      "*",
      "##### Install Ruby",
      "*",
      "##### Install Gems",
      "*",
      "##### Run Sprout",
      "*",
      "## Problems?",
      "+",
      "## Customization",
      "*",
      "## Caveats",
      "### Homebrew",
      "*",
      "## Development Tips & Tricks",
      "*",
      "## Roadmap",
      "*",
      "## Discussion List",
      "## References",
      "*"
    ]
  }
}
-->

# sprout-wrap

[![ci](https://github.com/LyraPhase/sprout-wrap/actions/workflows/ci.yml/badge.svg)](https://github.com/LyraPhase/sprout-wrap/actions/workflows/ci.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![pre-commit](https://github.com/LyraPhase/sprout-wrap/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/LyraPhase/sprout-wrap/actions/workflows/pre-commit.yml)

# NOTE: This is a Fork 🍴⚠️ 🔱

This project uses [soloist](https://github.com/mkocher/soloist) and [librarian-chef](https://github.com/applicationsonline/librarian-chef)
to run a custom set of the recipes in sprout-wrap's cookbooks.

Additionally, it adds the [`lyraphase_workstation`](https://github.com/trinitronx/lyraphase_workstation) cookbook for
installing a Digital Audio Workstation (DAW), and miscellaneous audio and development tools.

## Sponsor

Keeping this bootstrap provisioning project working on each macOS update sure is a lot of work!
If you find this project useful and appreciate my work,
would you be willing to click one of the buttons below to Sponsor this project and help me continue?

<!-- markdownlint-disable MD013  -->
| Method   | Button                                                                                                                 |
| :------- | :--------------------------------------------------------------------------------------------------------------------: |
| GitHub   | [💖 Sponsor](https://github.com/sponsors/trinitronx)                                                                   |
| Liberapay| [![Donate using Liberapay](https://liberapay.com/assets/widgets/donate.svg)](https://liberapay.com/trinitronx/donate)  |
| PayPal   | [![Donate with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/JamesCuzella) |
<!-- markdownlint-enable MD013  -->

Every little bit is appreciated! Thank you! 🙏

## Prerequisites

This guide assumes that you have an Apple machine running a recent version of macOS.

The Semi-Manual way section assumes that you know how to use RVM to install Ruby and Bundler to install Ruby Gems,
but gives some commands to assist you in installing the supported versions.

## Installation on macOS

### The Easy Way 🚀

#### 1. Run bootstrap script

Open a terminal and run:

    \curl -Ls https://git.io/Jy0EQ | bash

Alternatively, run:

    git clone https://github.com/LyraPhase/sprout-wrap.git
    cd sprout-wrap
    make bootstrap

### The Semi-Manual Way 💪

#### 1. Install Command Line Tools

[Download](https://developer.apple.com/support/xcode/) and install XCode or the XCode command line tools.

    xcode-select --install

#### Installation

To provision your machine, open up Terminal and enter the following:

    sudo xcodebuild -license
    xcode-select --install
    git clone https://github.com/LyraPhase/sprout-wrap.git
    cd sprout-wrap

#### 2. Ruby Installation

##### Install RVM

    bash -c "./bootstrap-scripts/bootstrap-rvm.sh $USER"
    export PATH="$PATH:$HOME/.rvm/bin"
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
    sprout_ruby_version=$(tr -d '\n' < "${REPO_BASE}/.ruby-version")
    sprout_ruby_gemset=$(tr -d '\n' < "${REPO_BASE}/.ruby-gemset")
    sprout_rubygems_ver=$(tr -d '\n' < "${REPO_BASE}/.rubygems-version") ## Passed to gem update --system
    sprout_bundler_ver=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | tr -d '[:blank:]')

##### Install Ruby

    # Install Ruby, Create Gemset and install Bundler + RubyGems
    ## NOTE: You might need to set compilation options for native gem extensions (e.g.: libffi, nokogiri)
    rvm install "ruby-${sprout_ruby_version}"
    rvm use "ruby-${sprout_ruby_version}"
    rvm gemset create "$sprout_ruby_gemset"
    rvm use "ruby-${sprout_ruby_version}"@"${sprout_ruby_gemset}"
    rvm "${sprout_ruby_version}" do gem update --system "${sprout_rubygems_ver}"
    rvm "${sprout_ruby_version}" do gem install --default "bundler:${sprout_bundler_ver}"
    if ! bundle list | grep -q "bundler.*${sprout_bundler_ver}"; then
      bundle exec gem install --default "bundler:${sprout_bundler_ver}"
    fi

##### Install Gems

    bundle config set --local path 'vendor/bundle' ;
    bundle config set --local without 'development' ;
    bundle install

##### Run Sprout

    caffeinate ./sprout

The `caffeinate` command will keep your computer awake while installing;
depending on your network connection, `soloistrc`, and `run_list`,
soloist can take from 10 minutes to 2 hours to complete.

## Problems?

### ObjectiveC Fork Error

As of macOS `10.14`, the [behavior of underlying ObjectiveC macOS Foundation framework changed][objc-fork-mojave].
(Big surprise, Apple changes fundamental development platform dependencies so often it causes many things to break 🍎💩)

This results in the following errors:

<!-- markdownlint-disable MD013  -->
    objc[37813]: +[__NSPlaceholderDictionary initialize] may have been in progress in another thread when fork() was called.
    objc[37813]: +[__NSPlaceholderDictionary initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
    [2020-07-20T16:25:31-06:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process terminated by signal 6 (IOT)
    [2020-07-20T16:25:31-06:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process terminated by signal 6 (IOT)
<!-- markdownlint-enable MD013  -->

The workaround is to run `soloist` / `chef-solo` with the following environment variable:

    export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
    bundle exec soloist run_recipe homebrew::install_casks ## For example

### clang error

If you receive errors like this:

    clang: error: unknown argument: '-multiply_definedsuppress'

then try downgrading those errors like this:

    sudo ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future bundle

### Command Line Tool Update Server

If you receive a message about the update server being unavailable and are on Mavericks,
then you already have the command line tools.

## Customization

This project uses [soloist](https://github.com/mkocher/soloist) and
[librarian-chef](https://github.com/applicationsonline/librarian-chef)
to run a subset of the recipes in sprout's cookbooks.

[Fork it](https://github.com/LyraPhase/sprout-wrap/fork) to customize its
[attributes](http://docs.chef.io/attributes.html) in [soloistrc](/soloistrc) and the list of recipes you'd like to use
for your team. You may also want to add other cookbooks to its [Cheffile](/Cheffile), perhaps one of the many
[community cookbooks](https://supermarket.chef.io/cookbooks). By default it configures an macOS workstation for
development and as a Digital Audio Workstation environment.

Finally, if you've never used Chef before - we highly recommend you buy &amp; watch
[this excellent 17 minute screencast](http://railscasts.com/episodes/339-chef-solo-basics) by Ryan Bates.

## Caveats

### Homebrew

- Homebrew path prefix [has changed](https://github.com/Homebrew/discussions/discussions/417) on Apple Silicon to `/opt/homebrew`.
  You may encounter issues after migrating from an Intel Mac unless running under Rosetta `Terminal.app`.
  Fresh installs on `arm64` based hardware will use the new location and compile natively for Apple Silicon.
- Homebrew cask has been [integrated](https://github.com/caskroom/homebrew-cask/pull/15381) with Homebrew proper.
  If you are experiencing problems installing casks and have an older installation of Homebrew,
  running `brew uninstall --force brew-cask; brew update` should fix things.
- If you are updating from an older version of `sprout-wrap`, your homebrew configuration in `soloistrc` might be under
  `node_attributes.sprout.homebrew.formulae` and `node_attributes.sprout.homebrew.casks`.
  These will need to be updated to `node_attributes.homebrew.formulas` (note the change from formulae to formulas)
  and `node_attributes.homebrew.casks`.

## Development Tips & Tricks

Some helpful commands and tricks to know when working on this repo:

1. To run `bootstrap.sh` with a custom `soloistrc`:

        export SOLOISTRC='soloistrc.lyra.yml'

2. To test `bootstrap.sh` `curl` piped to `bash` mode on a development branch (with `set -x` trace mode):

   <!-- markdownlint-disable MD013  -->
        export SPROUT_WRAP_BRANCH=my-feature-branch
        export SOLOISTRC=soloistrc.my-feature-test
        \curl -Ls https://raw.githubusercontent.com/LyraPhase/sprout-wrap/${SPROUT_WRAP_BRANCH}/bootstrap-scripts/bootstrap.sh | bash -x
   <!-- markdownlint-enable MD013  -->

3. To replicate what `bootstrap` CI workflow does:

        export CI=true
        # Ensure you have same Ruby + RubyGems + Bundler versions
        bundle install
        bundle exec make bootstrap

4. To replicate what `test` CI workflow does:

        export CI=true
        # Ensure you have same Ruby + RubyGems + Bundler versions
        bundle install
        bundle exec make test

5. To run `sprout`:

        make sprout

6. For extra Makefile targets:

        make help

## Roadmap

See LyraPhase Sprout Project Tracker: <https://github.com/orgs/LyraPhase/projects/1>

## Discussion List

  Join [LyraPhase/sprout-wrap Discussions](https://github.com/LyraPhase/sprout-wrap/discussions) to discuss this fork.
  You might also want to join [sprout-users@googlegroups.com](https://groups.google.com/forum/#!forum/sprout-users)
  if you use Sprout. (**Note:** This may not be very active anymore)

## References

- Slides from @hiremaga's [lightning talk on Sprout](https://web.archive.org/web/20130925173508/http://sprout-talk.cfapps.io/#1)
  at Pivotal Labs in June 2013
- [Railscast on chef-solo](http://railscasts.com/episodes/339-chef-solo-basics) by Ryan Bates (PAID)

[objc-fork-mojave]: https://blog.phusion.nl/2017/10/13/why-ruby-app-servers-break-on-macos-high-sierra-and-what-can-be-done-about-it/
