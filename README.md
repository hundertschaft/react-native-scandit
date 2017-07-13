
# react-native-scandit

## Getting started

`$ npm install react-native-scandit@https://github.com/salathegroup/react-native-scandit.git --save`

### Mostly automatic installation

`$ react-native link react-native-scandit`

Notes:
- Scandit's SDK is required. See below how add it to iOS and Android projects)
- You might need to allow access to the camera, both for iOS and Android

### Manual installation


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


### Add Scandit SDK

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

#### Android

1. Download Scandit SDK for Android (https://ssl.scandit.com/sdk, Scandit account required) and uncompress the archive.
2. Add the following to your project's app build.gradle (the file is in the ScanditSDK subfolder of the SDK):
  	```
  	repositories {
  	    flatDir{
  	        dirs '/PATH/TO/ScanditBarcodeScanner.aar'
  	    }
  	}
  	```


## Usage
```javascript
import React, { Component } from 'react';
import { AppRegistry, StyleSheet, View, Text } from 'react-native';

import Scandit, { ScanditPicker, ScanditSDKVersion } from 'react-native-scandit';

Scandit.setAppKey('<YOUR SCANDIT APP KEY>');

export default class ex2 extends Component {
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

AppRegistry.registerComponent('MyFirstScanditApp', () => >MyFirstScanditApp);
```

## Available Settings
```
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

## React Native Props:

`settings`: Scandit picker settings (see above)

`onScan`: on scan, called with the full object passed by Scandit's SDK

`onCodeScan`: on scan, called with the last scanned barcode only

`onSettingsChange`: obvious. Can be used to update the interface (i.e. a button that shows “Use front camera” / “Use back camera”)


## JS:

`getSettings(): Promise<*>`

`setSettings(settings: SettingsType): Promise<*>`

`startScanning(): Promise<*>`

These return a promise, that can resolve or reject. On Android, I had to resolve to a promise implementation on the JS side (see SGNativeComponent.js), since React Native doesn’t seem to handle it (did I miss something?).


`startScanningInPausedState()`

`stopScanning()`

`pauseScanning()`

`resumeScanning()`

These don’t return a promise but could. As everything was quite experimental, I didn’t reach that point.


`activity()`: string

Ideally, this should return the current state ('active', 'paused', or 'stopped'), but it doesn't (TODO kind of thing...).
