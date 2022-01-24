fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios unit_test

```sh
[bundle exec] fastlane ios unit_test
```



### ios build_swiftpm

```sh
[bundle exec] fastlane ios build_swiftpm
```



### ios cocoapods_liblint

```sh
[bundle exec] fastlane ios cocoapods_liblint
```



### ios lint

```sh
[bundle exec] fastlane ios lint
```



### ios lintfix

```sh
[bundle exec] fastlane ios lintfix
```



### ios patch

```sh
[bundle exec] fastlane ios patch
```

Release a new version with a patch bump_type

### ios minor

```sh
[bundle exec] fastlane ios minor
```

Release a new version with a minor bump_type

### ios major

```sh
[bundle exec] fastlane ios major
```

Release a new version with a major bump_type

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
