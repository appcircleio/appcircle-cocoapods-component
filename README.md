# Appcircle Cocoapods

Cocoapods is a dependency manager for Swift and Objective-C applications. Cocoapods handles the installation of external libraries your application depends on during a build.

Cocoapods is widely used among iOS developers for dependency management and it's very easy to include it in your iOS projects with Appcircle.

## Adding Cocoapods to your repository
Appcircle will look for the `Podfile.lock` file in your repository and use the specified Cocoapods version to install the dependencies.

If your `Podfile.lock` file doesn't specify a Cocoapods version, default Cocoapods version in the virtual machine will be used.
You need to specify an Xcode Workspace .xcworkspace file instead of an Xcode Project .xcodeproj file when you use Cocoapods as the dependency manager.

Required Input Variables
- `$AC_PROJECT_PATH`: Specifies the project path

Optional Input Variables
- `$AC_REPOSITORY_DIR`: Specifies the cloned repository directory.
- `$AC_COCOAPODS_VERSION`: Specifies cocoapods version.
