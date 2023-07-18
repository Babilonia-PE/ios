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
### ios known_flags
```
fastlane ios known_flags
```

### ios sync_certs
```
fastlane ios sync_certs
```
Sync development, adhoc and appstore certificates or the one, provided by MATCH_TYPE environment variable
### ios make_certs
```
fastlane ios make_certs
```
Make development, adhoc and appstore certificates or the one, provided by MATCH_TYPE environment variable
### ios deploy
```
fastlane ios deploy
```
Make a build, export it into an archive and upload to the Crashlytics
### ios bump_version
```
fastlane ios bump_version
```
Bump type to be used to increment version. Available values are: 'major', 'minor', patch. Default is 'patch'
### ios bump_build_number
```
fastlane ios bump_build_number
```
Bump type to be used to increment version. Available values are: 'major', 'minor', patch. Default is 'patch'
### ios upload_symbols
```
fastlane ios upload_symbols
```
Download symbols from the AppStore and upload to the Crashlytics

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
