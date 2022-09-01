fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### generate_icons

```sh
[bundle exec] fastlane generate_icons
```

Generates all icon sets and commits the changes.

### take_screenshots

```sh
[bundle exec] fastlane take_screenshots
```

Takes all screenshots required for the App Store and commits the changes.

### bump_version_numbers

```sh
[bundle exec] fastlane bump_version_numbers
```

Bumps all version numbers and commits the version bump.

**Parameters**
- `bump_type`: `major` or `minor` or `patch` (defaults to `patch`)

### build_and_upload_to_testflight

```sh
[bundle exec] fastlane build_and_upload_to_testflight
```

Downloads certificates and provisioning profiles, bumps build numbers, commits the build bump, archives the app and uploads the binary to TestFlight.

### build_and_upload_to_app_store

```sh
[bundle exec] fastlane build_and_upload_to_app_store
```

Downloads certificates and provisioning profiles, bumps build numbers, commits the build bump, archives the app and uploads the binary and all metadata to the App Store.

### git_release

```sh
[bundle exec] fastlane git_release
```

Merges release into main branch and publishes as a GitHub release.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
