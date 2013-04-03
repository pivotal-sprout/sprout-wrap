# sprout-wrap-ruby

Prepares a Mac running OS X Mountain Lion for Ruby development using [soloist](https://github.com/mkocher/soloist) and [Pivotal Workstation](https://github.com/pivotal/pivotal_workstation)

## Installation

### 1. Install XCode

[![Xcode - Apple](http://r.mzstatic.com/images/web/linkmaker/badge_macappstore-lrg.gif)](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4)

### 2. Install Command Line Tools
  
  XCode > Preferences > Downloads
  
### 3. Clone this project
  
    git clone https://github.com/hiremaga/sprout-wrap-ruby.git
    cd sprout-wrap-ruby
  
### 4. Install soloist & and other required gems

    sudo gem install bundler
    bundle

### 5. Run soloist
  
    bundle exec soloist
