# Mavenlink Workstation Setup

[![Build Status](https://travis-ci.org/mavenlink-cookbooks/sprout-wrap.png?branch=master)](https://travis-ci.org/mavenlink-cookbooks/sprout-wrap)

This project is a fork of [pivotal-sprout/sprout-wrap](https://github.com/pivotal-sprout/sprout-wrap/)

Follow the these instructions to bootstrap a blank OSX installation into a functional mavenlink development environment.

1. **Create SSH Key**

    See [generating-ssh-keys](https://help.github.com/articles/generating-ssh-keys) for more information. Use `services+WORKSTATION_NAME@mavenlink.com` as the email if you're setting up a workstation.

        ssh-keygen -t rsa -C "youremail@mavenlink.com"

1. **Install XCode**

    [![Xcode - Apple](http://r.mzstatic.com/images/web/linkmaker/badge_macappstore-lrg.gif)](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4)

1. **Install Command Line Tools**

        XCode.app > Preferences > Downloads

1. **Clone this project**

        git clone git@github.com:mavenlink-cookbooks/sprout-wrap.git
        cd sprout-wrap

1. **Install soloist & and other required gems in sprout-wrap repo dir**

        sudo gem install bundler
        bundle

1. **Run soloist**

        bundle exec soloist

1. **Bootstrap mavenlink app**

        mavenlink
        bundle
        bundle exec rake db:create
        migrate
        bundle exec rake db:seed


*note: DO NOT EDIT below this line so we can continue to merge upstream changes to the README.md into our fork*

# sprout-wrap

[![Build Status](https://travis-ci.org/pivotal-sprout/sprout-wrap.png?branch=master)](https://travis-ci.org/pivotal-sprout/sprout-wrap)

This project uses [soloist](https://github.com/mkocher/soloist) and [librarian-chef](https://github.com/applicationsonline/librarian-chef)
to run a subset of the recipes in sprout's [cookbooks]((https://github.com/pivotal-sprout/sprout).

[Fork it](https://github.com/pivotal-sprout/sprout-wrap/fork) to 
customize its [attributes](http://docs.opscode.com/chef_overview_attributes.html) in [soloistrc](/soloistrc) and the list of recipes 
you'd like to use for your team. You may also want to add other cookbooks to its [Cheffile](/Cheffile), perhaps one 
of the many [community cookbooks](http://community.opscode.com/cookbooks). By default it configures an OS X 
Mountain Lion workstation for Ruby development.

Finally, if you've never used Chef before - we highly recommend you buy &amp; watch [this excellent 17 minute screencast](http://railscasts.com/episodes/339-chef-solo-basics) by Ryan Bates. 

## Installation

### 1. Install XCode

[![Xcode - Apple](http://r.mzstatic.com/images/web/linkmaker/badge_macappstore-lrg.gif)](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4)

### 2. Install Command Line Tools
  
  XCode > Preferences > Downloads
  
### 3. Clone this project
  
    git clone https://github.com/pivotal-sprout/sprout-wrap.git
    cd sprout-wrap
  
### 4. Install soloist & and other required gems

    sudo gem install bundler
    bundle

### 5. Run soloist
  
    bundle exec soloist
