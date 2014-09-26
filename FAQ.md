# FAQ

#### Why does my chef run bomb out? Why can't I get my recipe to converge?

Make sure you're using system ruby, not rvm or rbenv ruby.  If you're not sure, run the following command and check that the output is `/usr/bin/ruby`:

```
$ which ruby
/usr/bin/ruby
```

Longer answer:  We test against system ruby, which is a good common denominator.  Also, using system ruby will bypass ownership issues (i.e. gems owned by root but installed under one's home directory).

#### Why do my edits keep getting reverted?  I change the recipe, but every time I run soloist it's changed back.

You're editing the recipe under `sprout-wrap/cookbooks`.  That is a directory that is checked-out from the sources (as defined in `Cheffile`) every chef run&mdash;overwriting your changes.

Make your changes under `sprout-wrap/site-cookbooks` instead; those changes won't be overwritten.

#### Why does sprout-wrap install an older version of RubyMine even though sprout's RubyMine recipe specifies a newer one?

You need to update the git SHAs specified in sprout-wrap's `Cheffile.lock`.  Run the following command in the root of your copy of the sprout-wrap repo:

```
librarian-chef update
```

#### Why not use the standalone Command Line Tools for XCode instead of XCode?

There are primarily 2 reasons that we install XCode in sprout-wrap:
    
1. System Ruby on OS X Mountain Lion uses `xcrun` to detect `cc`. `xcrun` is [not designed](http://stackoverflow.com/questions/13041525/osx-10-8-xcrun-no-such-file-or-directory) to work with the standalone Command Line Tools.
2. sprout-wrap is used to build workstations for iOS development. Having XCode available is handy in this situation.
