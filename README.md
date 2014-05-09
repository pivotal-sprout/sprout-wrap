# sprout-wrap

[![Build Status](https://travis-ci.org/pivotal-sprout/sprout-wrap.png?branch=master)](https://travis-ci.org/pivotal-sprout/sprout-wrap)

This project uses [soloist](https://github.com/mkocher/soloist) and [librarian-chef](https://github.com/applicationsonline/librarian-chef)
to run a subset of the recipes in sprout's cookbooks.

[Fork it](https://github.com/pivotal-sprout/sprout-wrap/fork) to 
customize its [attributes](http://docs.opscode.com/chef_overview_attributes.html) in [soloistrc](/soloistrc) and the list of recipes 
you'd like to use for your team. You may also want to add other cookbooks to its [Cheffile](/Cheffile), perhaps one 
of the many [community cookbooks](http://community.opscode.com/cookbooks). By default it configures an OS X 
Mavericks workstation for Ruby development.

Finally, if you've never used Chef before - we highly recommend you buy &amp; watch [this excellent 17 minute screencast](http://railscasts.com/episodes/339-chef-solo-basics) by Ryan Bates. 

## Installation under Mavericks (OS X 10.9)

### 1. Install XCode

[![Xcode - Apple](http://r.mzstatic.com/images/web/linkmaker/badge_macappstore-lrg.gif)](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4)

### 2. Agree to Terms

    xcodebuild -license
    
Or Fire up xcode and agree to terms from the GUI

### 3. Install Command Line Tools
  
    xcode-select --install

If you receive a message about the update server being unavailable and are on Mavericks, then you already have the command line tools.

### 4. Clone this project

    git clone https://github.com/awesomenesstv/sprout-wrap.git
    cd sprout-wrap

### 5. Install soloist & and other required gems

#### 5.a install bundler
If you're running under rvm or rbenv, you shouldn't preface the following commands with `sudo`.

`sudo gem install bundler`

#### 5.b install gems
***note:*** If you receive errors like this: `clang: error: unknown argument: '-multiply_definedsuppress'`, then try downgrading those errors like this: `sudo ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future bundle`

`sudo bundle`

### 6. Install private credentials
There is a thumb drive that has 2 important sets of credentials

#### 6.a IOS Code sigining certificates

The code signing certificates are required to build and deploy the app to the simulator/local IOS device/Testflight/App Store. There are 4 certificates located in a `Certificates.p12` file on the thumb drive.  You will need to open the file

`open /Volumes/ATVSecrets/Certificates.p12`

you will be prompted multiple times for passwords, both system and certificate pws they are all the current shared project password.  Once complete there should be 4 certificates with corresponding private keys installed in the users keychain.

#### 6.b Install Github ssh key

This is the ssh key you will use to clone/pull/push code to github with.

`mkdir ~/.ssh && cp /Volumes/ATVSecrets/.ssh/* ~/.ssh/`

#### 6.c Eject thumbdrive

`diskutil umount force /Volumes/ATVSecrets`

### 6. Run soloist

[You may want to modify your Energy Saver preferences (**System Preferences &rarr; Energy Saver &rarr; Computer Sleep &rarr; 3hrs**) because soloist usually takes 2-3 hours to complete.]

`soloist`

***note:*** the chef recipes rely on sudo access.  You should watch the output of soloist as it will prompt for the password to get sudo access.  It also has a lot of external network dependencies that sometimes fail. If the a recipe fails the entire soloist run is stopped.  The recipes are all [idempotent](http://en.wikipedia.org/wiki/Idempotence) and if you encounter a failure you should just re-run it.  If the failure continues you will need to look over the failure and see what the problem is.  Worst case you can edit the `soloistrc` file and comment out the offending recipe allowing you to build the rest of the system, and manually attempt to install the piece that is failing.

