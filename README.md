# Project Info

## Project base overview

#### Project is divided into frameworks:
- `Babilonia` - project itself. It contains all user flows, screens in flows (ViewControllers, Views, active Models) and related resources (assets, localized string, fonts...).
- `Core` - framework for core logic of app. It contains data passive models, structures stored in DB and app's services.

#### Resources
All resources (colors, strings, images) are generated via *SwiftGen* (https://github.com/SwiftGen/SwiftGen) to avoid usage of non-safe strings approach. It's integrated as cocoapod.

Resources are generated each time project is built.

#### Code styles
We use *SwiftLint* to support common code styles for better code reading. https://github.com/realm/SwiftLint.

## Architecture

We use modular approach as project's architecture: application is divided into logical flows (modules).
For screens and views in flows we use MVC or MVVM patterns where it's necessary.

## Templates

There are Xcode templates that can be found under `XCTemplates` folder within project directory. Templates can be used to speed up creation of new screens/flows.

To add templates to your Xcode just go to `~/Library/Developer/Xcode/Templates/` folder, create some new folder (e. g. `Babilonia Templates`) there and copy existing templates into newly created folder. 

## UI development

All screens (`UIViewController`s) and views (`UIView`s) are **code-based**. There is **NO nib files (`.storyboard`s or `.xib`s)** in the project! UI is done via code.

## Ensure Permissions

Make sure the script is executable. You can do this from the Terminal at your project's location:

- chmod +x `scripts/scripts/run-swiftlint.sh`
- chmod +x `scripts/scripts/copy-config.sh`
