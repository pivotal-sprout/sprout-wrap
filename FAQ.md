# FAQ

#### Why not use the standalone Command Line Tools for XCode instead of XCode?

There are primarily 2 reasons that we install XCode in sprout-wrap:
    
1. System Ruby on OS X Mountain Lion uses `xcrun` to detect `cc`. `xcrun` is [not designed](http://stackoverflow.com/questions/13041525/osx-10-8-xcrun-no-such-file-or-directory) to work with the standalone Command Line Tools.
2. sprout-wrap is used to build workstations for iOS development. Having XCode available is handy in this situation.
