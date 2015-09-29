travis-xcodebuild
=================

Drop-in replacement for running builds on Travis-CI with `xcodebuild` instead of `xctool`

# Installation
Either add `travis-xcodebuild` to your Gemfile and install with bundler, or add `gem install travis-xcodebuild` to your `install` steps in `.travis.yml` as:

```yaml
install:
  - gem install travis-xcodebuild
```

# Usage
Simply set the `script` step of `.travis.yml` to either:
 - `bundle exec travis-xcodebuild` (with Gemfile) or,
 - `travis-xcodebuild` (with normal gem installation)

The build command that is run a `clean analyze test`. Output is piped through the wonderful [`xcpretty`](https://github.com/supermarin/xcpretty) to clean it up for viewing it on the web, and raw `xcodebuild` output is saved to `output.txt` if you would like to archive it for debugging purposes.

# Options
`travis-xcodebuild` uses the normal `TRAVIS_XCODE_` settings for specifying the project/workspace and scheme to build.

For specifying the destination, set the `TRAVIS_XCODE_SDK` to the desired SDK/OS version, and optionally specify an `IOS_PLATFORM_NAME` environment variable (defaults to 'iPad').

Because everything is run through `xcodebuild` you can also specify other environment variable, such as `CONFIGURATION_BUILD_DIR` or `CLANG_STATIC_ANALYZER_MODE` and `xcodebuild` will respect them.

For example if your `.travis.yml` looks like this:
```yaml
xcode_workspace: MyAppSpace.xcworkspace
xcode_scheme: MyApp
xcode_sdk: iphonesimulator7.1
env:
  global:
    - CONFIGURATION_BUILD_DIR=build
    - CLANG_STATIC_ANALYZER_MODE=deep
    - IOS_PLATFORM_NAME='iPhone Retina (4-inch)'
script: bundle exec travis-xcodebuild
```
It will yeild a build command of:

`xcodebuild -workspace MyAppSpace.xcworkspace -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone Retina (4-inch),OS=7.1' clean analyze test`

And will perform a deep static analysis, and put the build results in the `build/` directory.
