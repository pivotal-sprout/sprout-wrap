# [Mavenlink](http://www.mavenlink.com) Workstation Setup

[![Build Status](https://travis-ci.org/mavenlink-cookbooks/sprout-wrap.png?branch=master)](https://travis-ci.org/mavenlink-cookbooks/sprout-wrap)

This project is a fork of [pivotal-sprout/sprout-wrap](https://github.com/pivotal-sprout/sprout-wrap/)

Follow the these instructions to bootstrap a blank OSX installation into a functional [Mavenlink](http://www.mavenlink.com) development environment.

1. **Enable FileVault in System Preferences**

    FileVault is full disk encryption, enable in Security preference panel, DO NOT LOSE THE KEY (or/and send them to your supervisors)

        System Preferences > Security & Privacy > Turn ON FileVault

1. **Create SSH Key**

    See [generating-ssh-keys] with no paraphrase. (https://help.github.com/articles/generating-ssh-keys) for more information. 
Use `services+WORKSTATION_NAME@mavenlink.com` as the email if you're setting up a workstation.

        ssh-keygen -t rsa -C "youremail@mavenlink.com"

1. **Install XCode**

    [![Xcode - Apple](http://r.mzstatic.com/images/web/linkmaker/badge_macappstore-lrg.gif)](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4)

1. **Install Command Line Tools**

        xcode-select --install

1. **Clone this project**

        git clone git@github.com:mavenlink-cookbooks/sprout-wrap.git
        cd sprout-wrap

1. **Install soloist & and other required gems in sprout-wrap repo dir**

        sudo gem install bundler
        sudo bundle

1. **Run soloist**

        bundle exec soloist

    If you prefer you can overload some options, such as Terminal.app color scheme:

        TERMINAL_SCHEME=Pro bundle exec soloist

1. **Bootstrap mavenlink app**

        mavenlink
        bundle
        bundle exec rake db:create
        migrate
        bundle exec rake db:seed

1. **Misc**

    https://sites.google.com/a/mavenlink.com/wiki/rubymine-licenses  
 
***
*note: DO NOT EDIT below this line so we can continue to merge upstream changes to the README.md into our fork*  
   
# sprout-wrap

[![Build Status](https://travis-ci.org/pivotal-sprout/sprout-wrap.png?branch=master)](https://travis-ci.org/pivotal-sprout/sprout-wrap)

This project uses [soloist](https://github.com/mkocher/soloist) and [librarian-chef](https://github.com/applicationsonline/librarian-chef)
to run a subset of the recipes in sprout's [cookbooks]((https://github.com/pivotal-sprout/sprout).

[Fork it](https://github.com/pivotal-sprout/sprout-wrap/fork) to 
customize its [attributes](http://docs.opscode.com/chef_overview_attributes.html) in [soloistrc](/soloistrc) and the list of recipes 
you'd like to use for your team. You may also want to add other cookbooks to its [Cheffile](/Cheffile), perhaps one 
of the many [community cookbooks](http://community.opscode.com/cookbooks). By default it configures an OS X 
Mavericks workstation for Ruby development.

Finally, if you've never used Chef before - we highly recommend you buy &amp; watch [this excellent 17 minute screencast](http://railscasts.com/episodes/339-chef-solo-basics) by Ryan Bates. 

## Installation under Mavericks (OS X 10.9)

### 1. Install XCode

[![Xcode - Apple](http://r.mzstatic.com/images/web/linkmaker/badge_macappstore-lrg.gif)](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4)

Don't forget to start up Xcode once it's installed so that you can agree to the terms&mdash;many commands won't work until the terms have been agreed to.

### 2. Install Command Line Tools
  
    xcode-select --install
  
### 3. Clone this project

    git clone https://github.com/pivotal-sprout/sprout-wrap.git
    cd sprout-wrap

### 4. Install soloist & and other required gems

If you're running under rvm or rbenv, you shouldn't preface the following commands with `sudo`.

    sudo gem install bundler
    sudo bundle

### 5. Run soloist

[You may want to modify your Energy Saver preferences (**System Preferences &rarr; Energy Saver &rarr; Computer Sleep &rarr; 3hrs**) because soloist usually takes 2-3 hours to complete.]

    TYPE_INSTALL=full bundle exec soloist

If you don't want OSX applications to be installed just omit TYPE_INSTALL=full

