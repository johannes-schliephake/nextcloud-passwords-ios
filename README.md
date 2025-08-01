# Passwords for Nextcloud (iOS Client)

<img src="https://raw.githubusercontent.com/johannes-schliephake/nextcloud-passwords-ios/main/Icon.svg" width="150">

An iOS client for the [Nextcloud Passwords](https://git.mdns.eu/nextcloud/passwords) app. Available on the [App Store](https://apps.apple.com/app/id1546212226).

This app allows you to view, create, edit and delete entries on your Nextcloud server. It offers a variety of filtering and sorting options. End-to-end/client-side encryption and encrypted offline storage make sure your data is secure.

A Password AutoFill provider is integrated into the app for seamless login experiences. You can enable this feature in iOS's Settings app.

This app requires a Nextcloud server with the Passwords app installed.

<img src="https://raw.githubusercontent.com/johannes-schliephake/nextcloud-passwords-ios/main/fastlane/screenshots/en-US/iPhone%2016%20Pro-1.png" width="19%"> <img src="https://raw.githubusercontent.com/johannes-schliephake/nextcloud-passwords-ios/main/fastlane/screenshots/en-US/iPhone%2016%20Pro-2.png" width="19%"> <img src="https://raw.githubusercontent.com/johannes-schliephake/nextcloud-passwords-ios/main/fastlane/screenshots/en-US/iPhone%2016%20Pro-3.png" width="19%"> <img src="https://raw.githubusercontent.com/johannes-schliephake/nextcloud-passwords-ios/main/fastlane/screenshots/en-US/iPhone%2016%20Pro-4.png" width="19%"> <img src="https://raw.githubusercontent.com/johannes-schliephake/nextcloud-passwords-ios/main/fastlane/screenshots/en-US/iPhone%2016%20Pro-5.png" width="19%">

## TestFlight

You can install beta builds by joining the [TestFlight](https://testflight.apple.com/join/iuljLJ4u) program. These builds also include logging functionality to get detailed information about errors.

## Translators

- Czech: [Pavel Borecki](https://github.com/p-bo)
- French: [Maxime Killinger](https://github.com/maxime-killinger)
- Russian: [jensaymoo](https://github.com/jensaymoo)
- Norwegian: [Allan Nordhøy](https://github.com/comradekingu)
- Catalan: [Maite Guix](https://hosted.weblate.org/user/maite.guix)
- Swedish: [Anders Johansson](https://github.com/tellustheguru)
- Ukrainian: [Markevych Dmytro](https://github.com/Hotr1pak)
- Galician: [Miguel A. Bouzada](https://github.com/mbouzada)
- Polish: [Radosław Rudner](https://hosted.weblate.org/user/rudass)
- Tamil: [தமிழ் நேரம் (TamilNeram)](https://github.com/TamilNeram)
- Simplified Chinese: [Sketch6580](https://hosted.weblate.org/user/Sketch6580)
- Italian: [Luca](https://hosted.weblate.org/user/Pigro)
- Estonian: [Priit Jõerüüt](https://hosted.weblate.org/user/jrthwlate)

Everybody is welcome to contribute translations via [Weblate](https://hosted.weblate.org/engage/nextcloud-passwords-ios)!

## Development
Perform these steps to set up this project:
- Run `rbenv install` to install the matching Ruby version or manually install the version specified in the [.ruby-version](.ruby-version) file
- Run `gem install bundler` to install Bundler
- Run `bundle install` to install dependencies
- Run `brew install swiftlint swiftgen` to install SwiftLint & SwiftGen
- Launch the project with the Xcode version specfied in the [.xcode-version](.xcode-version) file
- Log into your Apple Developer Account in Xcode
- Adjust some project settings to be able to build the app:
  + Change the `PARENT_PRODUCT_BUNDLE_IDENTIFIER` build setting to something different for the *Passwords* project
  + Set your signing team for the *Passwords*, *Provider* & *Extension* targets
  + If you aren't subscribed to the Apple Developer Program:
    - Delete the *In-App Purchase* entitlement from the "Passwords" target
    - Delete the *AutoFill Credential Provider* entitlement from the *Passwords* & *Provider* targets<br>
      **Some features of the app will be missing after deleting these entitlements.**
