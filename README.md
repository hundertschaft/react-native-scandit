This is a working branch to integrate storybook. Only ready up on merge.

[![NPM](https://nodei.co/npm/react-native-scandit.png?compact=true)](https://npmjs.org/package/react-native-scandit)

# react-native-scandit

>We (Shoplink GmbH) are a premium scandit-partner and in the process of merging our internal react-native bridge into this repository for public access. This project was originally created [by @Boris-c](https://github.com/salathegroup/react-native-scandit) at the Digital Epidemiology Lab at EPFL, Switzerland (Salathe Group). 

## Run the iOS & Android Demo App

 - If you don't have an account, [register on Scandit](https://ssl.scandit.com/customers/new?p=test) for a 30 day trail.
 - Download the Scandit iOS and Android BarcodeScan SDK
 - Clone this Repository
 - Go into `_demo_/`
 - Set your API Key inside of the `.env` file
 - run `yarn install` (or `npm install` if you only use npm)
 - **Android**
   - Copy the `ScanditSDK` folder (containing the .aar file in its root) into `android/app/src/vendor/`
   - Start the App in the emulator or device via `react-native run-android` (emulator: you need to set a webcam as a camera in your emulator to test barcode scanning)
 - **iOS**
   - Copy the `ScanditSDK` folder (containing the .framework file in its root) into `ios/`
   - Open the `scandit.xcodeproj` with xcode and set your developer account for the targets `scandit` & `scanditTests`
   - Connect your iOS device and run the build from xcode (simulator has no camera)

## Installation

`$ react-native install react-native-scandit`

Note:
- Scandit's SDK is required. See below how to add it to the iOS and Android projects.
- You need to allow access to the camera, both for iOS and Android. Barcode scanning can not be tested in the iOS Simulator.

## Manual Package installation

`$ yarn install react-native-scandit`

#### iOS

1. In Xcode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-scandit` and add `SGScandit.xcodeproj`
3. In Xcode, in the project navigator, select your project. Add `libSGScandit.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.SGScanditPackage;` to the imports at the top of the file
  - Add `new SGScanditPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-scandit'
  	project(':react-native-scandit').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-scandit/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-scandit')
  	```

## Add Scandit SDK
#### iOS

1. Download Scandit SDK for iOS (https://ssl.scandit.com/sdk, Scandit account required) and uncompress the archive.
2. Copy the `ScanditSDK` folder to your `ios/` folder. Note: This project assumes your ios project is under `ios/` — if not, you need to change the relative Framework Header Search path in the SGScandit.xcodeproj manually.
3. Continue with the [Scandit install documentation](http://docs.scandit.com/stable/ios/ios-integrate.html) (which is at the time as follows):
  - Drag the `ScanditBarcodeScanner.framework` from your `ios/ScanditSDK` folder (Finder) *inside xcode*, into your projects `Frameworks/` group. (If you don't have a Frameworks Group, create one via right click -> Create Group. Name it "Frameworks").
  - A Model Pops-Up asking how xcode should add this file. Check both "Copy Items when needed" & "Create Groups". Select your target (should be selected) & hit ok.
  - Drag the `ScanditBarcodeScanner.bundle` from inside the frameworks package (ios/ScanditSDK/ScanditBarcodeScanner.framework/Resources/ScanditBarcodeScanner.bundle) into the Frameworks group as well.
  - The result should look something like this:
 ![AddedFrameworkAndBundle](http://docs.scandit.com/stable/ios/img/ios/GettingStarted/AddedFrameworkAndBundle.png)

4. Scandit requires additional native libraries. At a minimum `libiconv.tbd`, `libz.tbd` and `MediaPlayer.framework` (if it does not compile, check the scandit documentation for the others libraries/frameworks and add the ones you are missing). Add them by selecting your Project-Root in Xcode -> Select your Target and add them under `Linked Frameworks and Libraries` via the "+".
5. Scandit requires camera access. Make sure to add the "Privacy - Camera access" to your info.plist file in xcode (click "+" at the top and search for "Privacy - Camera..." via the auto complete. As a value, write a short description for what the camera will be used. For example "Camera is needed to scan barcode".
6. Don't forget: You can not use the Camera in the simulator. So you need to **use a real device for testing** (!). 

#### Android

1. Download Scandit SDK for Android (https://ssl.scandit.com/sdk, Scandit account required) and uncompress the archive. The rest is in line with [scandit android setup documentation](http://docs.scandit.com/stable/android/android-integrate.html) by doing the following...
2. Create a folder named `vendor` inside of `android/app/src/`.
3. Place the ScanditSDK folder (the one containing the .aar file in its root) from the archive into `android/app/src/vendor/` so that the path to the ScanditSDK is `your-rn-project/android/app/src/vendor/ScanditSDK/ScanditBarcodeScanner.aar`.
4. Add to the `android/build.gradle`file the flatdir path `$rootDir/app/src/vendor/ScanditSDK`. Do that inside of the `allprojects { repositories {` section, so the final result looks something like this:
```java
(..)
allprojects {
    repositories {
        mavenLocal()
        jcenter()
        // SCANDIT INSERT ----->
        flatDir {
            dirs "$rootDir/app/src/vendor/ScanditSDK"
        }
        // <----- SCANDIT INSERT END
        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url "$rootDir/../node_modules/react-native/android"
        }
    }
}
```
5. Go into your `android/app/build.gradle` und add to the dependencies section (located at the end of the gradle file) the line `compile(name:'ScanditBarcodeScanner', ext:'aar')` **BEFORE** the "`compile project(':react-native-scandit')`", so that your dependencies look something like this:
```java
(..)
dependencies {
    // (..)
    compile(name:'ScanditBarcodeScanner', ext:'aar') // <--- INSERT BEFORE react-native-scandit compile statement
    compile project(':react-native-scandit')
    // (..)
    compile fileTree(dir: "libs", include: ["*.jar"])
    compile "com.android.support:appcompat-v7:23.0.1"
    compile "com.facebook.react:react-native:+"  // From node_modules
}
(..)
```
6. Scandit requires camera access. Make sure to add to your `AndroidManifest.xml` (under `android/app/src/main/`) the folliwng permission:
```xml
    <uses-permission android:name="android.permission.CAMERA"/>
```

## Usage
```javascript
import React, { Component } from 'react';
import { AppRegistry, StyleSheet, View, Text } from 'react-native';

import Scandit, { ScanditPicker, ScanditSDKVersion } from 'react-native-scandit';

Scandit.setAppKey('<YOUR SCANDIT APP KEY>');

export default class MyFirstScanditApp extends Component {
  render() {
    return (
      <View style={{ flex: 1 }}>
        <ScanditPicker
          ref={(scan) => { this.scanner = scan; }}
          style={{ flex: 1 }}
          settings={{
            enabledSymbologies: ['EAN13', 'EAN8', 'UPCE'],
            cameraFacingPreference: 'back'
          }}
          onCodeScan={(code) => {alert(code.data);}}
        />
      <Text>Using Scandit SDK {ScanditSDKVersion}</Text>
      </View>
    );
  }
}

AppRegistry.registerComponent('NAME_OF_RN_PROJECT', () => MyFirstScanditApp);
```

## Available Settings
```js
type ScanditSettingsType = {
  activeScanningAreaLandscape?: ScanditScanAreaType;
  activeScanningAreaPortrait?: ScanditScanAreaType;
  cameraFacingPreference?: 'front' | 'back';
  codeCachingDuration?: number;
  codeDuplicateFilter?: number;
  codeRejectionEnabled?: boolean;
  enabledSymbologies?: ScanditSymbologyType[];
  force2dRecognition?: boolean;
  highDensityModeEnabled?: boolean;
  matrixScanEnabled?: boolean;
  maxNumberOfCodesPerFrame?: number;
  motionCompensationEnabled?: boolean;
  relativeZoom?: number;
  restrictedAreaScanningEnabled?: boolean;
  scanningHotSpot?: ScanditPointType;
  workingRange?: 'standard' | 'long';
}
```
> Note: Due to traversal, boleans and numbers may have to be passed as strings. I.e. `true` = `"true"`.

## React Native Props:

`settings`: Scandit picker settings (see above)

`onScan`: on scan, called with the full object passed by Scandit's SDK

`onCodeScan`: on scan, called with the last scanned barcode only

`onSettingsChange`: obvious. Can be used to update the interface (i.e. a button that shows “Use front camera” / “Use back camera”)


## JS:

`getSettings(): Promise<*>`

`setSettings(settings: SettingsType): Promise<*>`

`startScanning(): Promise<*>`

>These return a promise, that can resolve or reject. On Android, I had to resolve to a promise implementation on the JS side (see SGNativeComponent.js), since React Native doesn’t seem to handle it (did I miss something?).


`startScanningInPausedState()`

`stopScanning()`

`pauseScanning()`

`resumeScanning()`

>These don’t return a promise but could. As everything was quite experimental, I didn’t reach that point.

`activity()`: string

>Ideally, this should return the current state ('active', 'paused', or 'stopped'), but it doesn't (TODO kind of thing...).

## Contribution
Please create issues if you encounter problems. In terms of contribution, Scandit maintains an [official cordova plugin](https://github.com/Scandit/barcodescanner-sdk-cordova). It is technically possible to migrate cordova plugins to react-native (see links below).
 - **Cordova Parity**: If you have some ideas how to do so, or see missing (promise based) implementations, feel free to reach out or issue pull requests.
 - **Testing**: If you have an idea for automatic testing of the bridge (continues integration, E2E tests), let us know.
 - **UI Overlays**: Scandit is a barcode scanner. In most cases, you want to display additional information on top of it without covering interaction elements. We show animations and other information when interacting with barcodes. However, a best practice of overlaying views is still missing.

#### Link Resources & Inspiration for Contribution

  - [Repo - Official Scandit Cordova Plugin](https://github.com/Scandit/barcodescanner-sdk-cordova)
  - [Article - Moving Cordova plugins to React-Native](https://medium.com/@psak.works/cordova-plugins-with-react-native-236183a4204b)
  - [Repo - Cordova Plugin Adapter for React Native](https://github.com/axemclion/react-native-cordova-plugin)
  - [Repo - A cordova plugin bridge for react-native](https://github.com/remobile/react-native-cordova)
  - [Article - Using Cordova plugins in ReactNative](http://blog.nparashuram.com/2016/04/using-cordova-plugins-in-reactnative.html)