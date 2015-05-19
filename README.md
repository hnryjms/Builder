Builder
=======

### Better Build Scripts for Your CI Server

Setting up Continuous Integration, Continuous Deployment and Continuous Delivery
systems can be difficult, and resolving failures can slow your productivity.

**Builder** is a collection of Ruby script classes to make it easy for you to write
CI Server tasks that run on both your machine and the CI server gracefully. These
Ruby scripts are set up to be imported through `require_relative` directly (not as
a Ruby gem).

## Getting Started

The best way to use **Builder** is to add it as a submodule to your project.

1. Add **Builder** as a git submodule.
1. Write & commit a Ruby task script in your repo (see example).
1. Run `./MyCoolScript.rb` and make sure it compiles.
1. Configure your CI Server to run `./MyCoolScript.rb`.

#### Example Build Script

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

The Apple Builder supports iOS and OS X apps, and can export to all formats
supported by `xcodebuild` (currently incldues `.app`, `.ipa`, `.pkg`). **Builder**
can take in both `.xcworkspace` and `.xcodeproj` locations, and each instance
can build a single scheme from your environment.

When available, [xctool](https://github.com/facebook/xctool/) is used in favor over
`xcodebuild` because of it's advanced reporting and formatting functionality, but
`xctool` is only required when testing, and build/archive tasks will resort to
`xcodebuild` when `xctool` cannot be found.

This Builder also automatically checks for [Cocoapods](https://cocoapods.org) and can
automatically install any Cocoapods dependencies before building, testing or archiving
your app.

##### Apple Build Functions

```ruby
MyApp = Builder::Apple.new(location, scheme)
```

Instantiate a new Apple Builder object for an `xcodeproj` or `xcworkspace` location, and scheme.

```ruby
MyApp.configuration = 'Release'
```

Set the Build Configuration to use when building & archiving your scheme (default is `Release`).

```ruby
MyApp.sdk = 'iphoneos'
```

Set the SDK to use when building & archiving your scheme (default is `iphoneos`). This can be
`iphoneos8.3`, `iphonesimulator`, or any other valid SDK identifier.

```ruby
MyApp.cocoapods = false
```

Explicitly enable or disable Cocoapods from being installed before the first build, test or
archive action. This is automatically determined by any Podfile existance.

```ruby
MyApp.build()
```

Build the scheme and do nothing with the product.

```ruby
MyApp.test(junit='./Results/junit.xml')
```

Build and test the scheme using the iOS Simulator, and write the results to a JUnit file
for a CI Server to parse as build results. **This requires xctool to be installed.**

```ruby
MyApp.archive(output="./#{self.scheme}.app", dSYMs=nil)
```

Build and export the scheme, and write the product and corresponding dSYMs to a file. The
output is automatically determined by the path extension; and `.app`, `.ipa`, `.pkg` are all
currently valid. The dSYMs will be written in a `.zip` format with all `.dSYM` packages at the
root of the archive (matching most IPA Distribution formats, i.e. HockeyApp).

---

**XCTOOL_PATH** will explicitly define the [xctool](https://github.com/facebook/xctool/) path
to be used when executing builds and tests. The default is to find `xctool` from inside the
`$PATH` settings. Setting the value to `false` will disable `xctool` building.

**XCODEBUILD_PATH** will explicitly define the path to `xcodebuild` to be used when executing
builds and tests. Keep in mind that `xctool` is used in favor of `xcodebuild`. The default is
to find `xcodebuild` from inside the `$PATH` settings.

**COCOAPODS_PATH** will explicitly define the `pods` path to be used when preparing the environment
to run tests, builds and archives. The default is to find `xctool` from inside the `$PATH` settings.

```
$ XCTOOL_PATH=/usr/local/bin/xctool ./MyScript.rb
$ XCTOOL_PATH=false ./MyScript.rb
$ XCODEBUILD_PATH=/Applications/Xcode-6.1.app/Contents/Developer/usr/bin/xcodebuild ./MyScript.rb
$ COCOAPODS_PATH=/usr/bin/pod ./MyScript.rb
```

#### More Platforms

More platforms are hopefully coming soon. Pull requests are welcome!

## License

**Builder** is licensed under the Creative Commons *Attribution 4.0 International (CC BY 4.0)*
license. More information about the license is available at the
[creative commons](http://creativecommons.org/licenses/by/4.0/) website.
