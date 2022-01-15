<!-- markdownlint-configure-file
{
  "line-length": {
    "line_length": 120,
    "heading_line_length": 120,
    "code_block_line_length": 120,
    "strict": true,
    "stern": true
  },
  "required-headers": {
    "headings": [
      "# FAQ",
      "+",
      "*"
    ]
  }
}
-->

# FAQ

## Why does my chef run bomb out? Why can't I get my recipe to converge?

### [Don't use system Ruby](https://dontusesystemruby.com)

Make sure you're **NOT using system ruby**, instead use a version of ruby from [`rvm`][1],
[`rbenv`][2], or [`chruby`][3].
If you're not sure, run the following command and check that the output **is NOT** `/usr/bin/ruby`:

```bash
$ which ruby
/usr/bin/ruby ## System Ruby
```

Longer answer:  It is difficult to test against all versions of system ruby which change in each macOS release.
System Ruby belongs to the operating system and can change at any time, and can't always be removed or repaired.
Installing Ruby with a version manager places ruby and gems under one's home directory.  It also allows for a single
tested, known-working version of Ruby to run the application against.
This project's supported Ruby version can be found in the `.ruby-version` file.  The supported version of `rubygems`
gem can be found in the `.rubygems-version` file.  The currently supported set of Gems can be found in the
`Gemfile.lock`.

## Why do my edits keep getting reverted?  I change the recipe, but every time I run soloist it's changed back

You're editing the recipe under `sprout-wrap/cookbooks`.  That is a directory that is checked-out from the sources
(as defined in `Cheffile`) every chef run&mdash;overwriting your changes.

Make your changes under `sprout-wrap/site-cookbooks` instead; those changes won't be overwritten.

## Why does sprout-wrap install an older version of RubyMine even though sprout's RubyMine recipe specifies a newer one?

You need to update the git SHAs specified in sprout-wrap's `Cheffile.lock`.
Run the following command in the root of your copy of the sprout-wrap repo:

```bash
librarian-chef update
```

## Why not use the standalone Command Line Tools for XCode instead of XCode?

There are primarily 2 reasons that we install XCode in sprout-wrap:

1. System Ruby on OS X >= Mountain Lion uses `xcrun` to detect `cc`.
  `xcrun` is [not designed](http://stackoverflow.com/questions/13041525/osx-10-8-xcrun-no-such-file-or-directory)
   to work with the standalone Command Line Tools.
2. sprout-wrap is used to build workstations for iOS development.
   Having XCode available is handy in this situation.

[1]: http://rvm.io
[2]: http://rbenv.org
[3]: https://github.com/postmodern/chruby#readme
