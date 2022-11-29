fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios unit_test
```
fastlane ios unit_test
```

### ios build_swiftpm
```
fastlane ios build_swiftpm
```

### ios cocoapods_liblint
```
fastlane ios cocoapods_liblint
```

### ios lint
```
fastlane ios lint
```

### ios lintfix
```
fastlane ios lintfix
```

### ios patch
```
fastlane ios patch
```
Release a new version with a patch bump_type
### ios minor
```
fastlane ios minor
```
Release a new version with a minor bump_type
### ios major
```
fastlane ios major
```
Release a new version with a major bump_type

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
