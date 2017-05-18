
# react-native-scandit

## Getting started

`$ npm install react-native-scandit --save`

### Mostly automatic installation

`$ react-native link react-native-scandit`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-scandit` and add `SGScandit.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libSGScandit.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
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


## Usage
```javascript
import SGScandit from 'react-native-scandit';

// TODO: What to do with the module?
SGScandit;
```
  