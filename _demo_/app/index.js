import React, { Component } from 'react';
import { AppRegistry, StyleSheet, View, Text } from 'react-native';

import Scandit, { ScanditPicker, ScanditSDKVersion } from 'react-native-scandit';

// =============================================================================
// For testing, set your Scandit SDK App Key inside of SCANDIT_KEY.js
// =============================================================================
import SCANDIT_KEY from "../SCANDIT_KEY.js";

Scandit.setAppKey(SCANDIT_KEY);

export default class App extends Component {
  render() {
    return (
      <View style={{ flex: 1 }}>
        <ScanditPicker
          ref={(scan) => { this.scanner = scan; }}
          style={{ flex: 1 }}
          settings={{
            enabledSymbologies: ['EAN13', 'EAN8', 'UPCE'],
            cameraFacingPreference: 'back',
            workingRange: 'short'
          }}
          onCodeScan={(code) => { alert(code.data); }}
        />
        <Text>Using Scandit SDK {ScanditSDKVersion}</Text>
      </View>
    );
  }
}

AppRegistry.registerComponent('scandit', () => App);