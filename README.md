# blackhole

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# tags 
git tag -a v1.8.0 -m 'added self certi.. and updated sdk'                create tag
git push origin v1.5                                            push tag


list tag 
git tag


Let's say you have created a new repo on github. So the first step would be to clone the repo:git clone {Your Repo URL}

You do your work, add some files, code etc., then push your changes with:

git add .
git commit -m "first commit"
git push
Now our changes are in main branch. Let's create a tag:

git tag v1.0.0                    # creates tag locally     
git push origin v1.0.0            # pushes tag to remote
If you want to delete the tag:

git tag --delete v1.0.0           # deletes tag locally    
git push --delete origin v1.0.0   # deletes remote tag

# verify app
android/app/build.gradle

android {

    signingConfigs {
        release {
            keyAlias 'your_alias_name'
            keyPassword 'keystore_password'
            storeFile file('../your_keystore_name.jks')
            storePassword 'keystore_password'
        }
    }

}
   
   also create the jks file in root directory
    keytool -genkey -v -keystore your_keystore_name.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your_alias_name

# version for android
android/app/build.gradle

android {
    // Other configurations...

    defaultConfig {
        applicationId "com.example.yourapp" // Replace with your app's package name
        minSdkVersion 21 // Minimum supported Android version
        targetSdkVersion 30 // Target Android version

        // Set the version code and version name here
        versionCode 1 // An integer value that represents the version of the app
        versionName "1.0" // A string that represents the version name of the app
    }

    // Other configurations...
}
# version for android
pubspec.yaml

name: your_flutter_app
description: A new Flutter project

# Set the app version here
version: 1.0.0

# to change version 
change in pubspec.yml and main dart and tag