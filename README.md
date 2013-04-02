# sprout-wrap-ruby

Prepares a Mac running OS X Mountain Lion for Ruby development with some help from [soloist](https://github.com/mkocher/soloist) and [Pivotal Workstation](https://github.com/pivotal/pivotal_workstation)

## Installation

### 1. Install XCode

[![Xcode - Apple](http://r.mzstatic.com/images/web/linkmaker/badge_macappstore-lrg.gif)](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4)

### 2. Install Command Line Tools
  
  XCode > Preferences > Downloads

### 3. Setup an SSH Key and upload to Github

    ssh-keygen -t rsa
    cat ~/.ssh/id_rsa.pub
    cat ~/.ssh/id_rsa.pub | pbcopy
  
### 4. Clone this project
  
    git clone git@github.com:hiremaga/workstation.git
    cd workstation
  
### 5. Install soloist & and other required gems

    sudo gem install bundler
    bundle install --binstubs

### 6. Run soloist
  
    bundle exec soloist
