import React, { Component } from 'react';
import { AppRegistry, StyleSheet, View, Text } from 'react-native';

import Scandit, { ScanditPicker, ScanditSDKVersion } from 'react-native-scandit';

// =============================================================================
// Set your Scandit SDK App Key inside of SCANDIT_KEY.js
// =============================================================================
import SCANDIT_KEY from "scandit/SCANDIT_KEY.js";

/* CHECK FOR KEY */
if (SCANDIT_KEY === "<YOUR SCANDIT APP KEY>") {
  console.warn("[MISSING KEY]: Set your Scandit App Key inside of SCANDIT_KEY.js before running this demo!")
}

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