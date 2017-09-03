import React, { Component } from 'react';
import { Platform, AppRegistry, StyleSheet, View, Text, Alert } from 'react-native';

import Scandit, { ScanditPicker, ScanditSDKVersion } from 'react-native-scandit';

// =============================================================================
// Set your Scandit SDK App Key inside of SCANDIT_KEY.js
// =============================================================================
import { SCANDIT_KEY_IOS, SCANDIT_KEY_ANDROID } from "scandit/CONFIG.js";

/* CHECK FOR KEY */
if (SCANDIT_KEY_IOS === "<YOUR SCANDIT APP KEY>" || SCANDIT_KEY_ANDROID === "<YOUR SCANDIT APP KEY>") {
  console.warn("[MISSING KEY]: Set your Scandit App Key inside of CONFIG.js before running this demo!")
}

/* Set AppKey */
(Platform.OS === "ios") ? Scandit.setAppKey(SCANDIT_KEY_IOS) : Scandit.setAppKey(SCANDIT_KEY_ANDROID);

// =============================================================================
// Scanner Component
// =============================================================================

export default class Scanner extends Component {

  onBarcode = (code) => {
    this.scanner.pauseScanning();
    Alert.alert("Detected Barcode",
      code.data,
      [{ text: 'CONTINUE', onPress: () => this.scanner.resumeScanning() }],
      { cancelable: false }
    );
  };

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
          onCodeScan={this.onBarcode}
        />
        <Text>Using Scandit SDK {ScanditSDKVersion}</Text>
      </View>
    );
  }
}