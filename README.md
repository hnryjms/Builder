Builder
=======

### Better Build Scripts for Your CI Server

Setting up Continuous Integration, Continuous Deployment and Continuous Delivery
systems is annoying and fragile. Making sure your CI Server is doing all the things
it needs to is also annoying.

**Builder** is a collection of Ruby script classes to make it easy for you to write
a CI Server task. These Ruby scripts are set up to be imported through `require_relative`
directly (not as a Ruby gem). You can pick and choose which scripts you want to
import to your repo and commit them directly, or add Builder as a git submodule
for easy updating.

## Getting Started

The best way to use **Builder** is to add it as a submodule to your project.

**Builder requires [xctool](https://github.com/facebook/xctool/)**

1. Add **Builder** as a git submodule.
1. Install `xctool` on both your CI Server and your computer.
    ```
    $ brew install xctool
    ```
1. Write a ruby script (see below).
1. Commit the submodule and your new script.
1. Run `./MyCoolScript.rb` and win.
1. Configure your CI Server to run `./MyCoolScript.rb` and win.

To use **Builder**, you'll need to write a new Ruby script referencing the script
for the platform you're integrating. Your script will look like something this:

```ruby
#!/usr/bin/ruby -w
require_relative '../Vendor/Builder/Apple.rb'

# Get the root of the git workspace.
Workspace = `git rev-parse --show-toplevel`
Workspace.strip!

# Do awesome things
MyApp = Builder::Apple.new("#{Workspace}/MyApp.xcodeproj", "MyScheme")
MyApp.test()
MyApp.archive('./MyApp.ipa', './MyApp.dSYMs.zip')
```

Each platform has unique qualities that help your integration easier.

## Platforms

#### Apple

The Apple platform supports iOS and OS X apps, and can export to all formats
supported by the `xcodebuild` export functionality (app, ipa, pkg). **Builder**
can take in both *xcworkspace* and *xcodeproj* locations, and requires a single scheme.

This script also automatically checks for [Cocoapods](https://cocoapods.org) and will
ensure that Cocoapods dependencies are installed before building, testing or archiving.

```ruby
# initializer
#
# location: path to xcodeproj or xcworkspace file
# scheme:   the scheme to build, test or archive from the location
App = Builder::Apple.new(location, scheme)

# build configuration (default 'Release')
App.configuration = 'Release'

# build sdk (default 'iphoneos', ALWAYS 'iphonesimulator' for tests)
App.sdk = 'iphoneos'

# prevent automatic installation of Cocoapods dependencies
App.cocoapods = false

# builds the scheme
App.build()

# builds (if necessary) and tests the scheme on iOS Simulator
#
# junit: path to write JUnit test results, as .xml, or nil
App.test(junit='./Results/junit.xml')

# builds and archives the scheme
#
# output: path to write artifact, as .xcarchive, .app, .ipa or .pkg
# dSYMs:  path to write dSYMs, as .zip archive, or nil
App.archive(output="./#{self.scheme}.app", dSYMs=nil)
```

##### Environment variables

The Apple platform script optionally can take several environment variables to modify
the behavior.

**XCTOOL_PATH** will explicitly define the path to [xctool](https://github.com/facebook/xctool/)
to be used when executing builds and tests. The default is to find `xctool` from inside the
`$PATH` settings.

**XCODEBUILD_PATH** will explicitly define the path to `xcodebuild` to be used when executing
builds and tests. Keep in mind that `xctool` is used in favor of `xcodebuild`. The default is
to find `xcodebuild` from inside the `$PATH` settings (`/usr/bin/xcodebuild`).

```
$ XCTOOL_PATH=/usr/local/bin/xctool ./MyScript.rb
$ XCODEBUILD_PATH=/Applications/Xcode-6.1.app/Contents/Developer/usr/bin/xcodebuild ./MyScript.rb
```

#### More

More platforms are hopefully coming soon. Pull requests are very welcome!

## License

**Builder** is licensed under the Creative Commons *Attribution 4.0 International (CC BY 4.0)*
license. More information about the license is available at the
[creative commons](http://creativecommons.org/licenses/by/4.0/) website.
