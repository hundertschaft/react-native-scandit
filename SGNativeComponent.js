/* @flow */

import React, { PropTypes, Component } from 'react';
import {
  findNodeHandle,
  NativeModules,
  Platform,
  requireNativeComponent,
  UIManager,
  View,
  Event,
} from 'react-native';

class NativeComponent extends Component {
  _nodeHandle: Object;

  nodeHandle() {
    if (!this._nodeHandle) {
      this._nodeHandle = findNodeHandle(this);
    }

    return this._nodeHandle;
  }

  dispatchCommand(command:any, args?: Array<any>) {
    // if (1 === 1) return;

    if (typeof command === 'undefined') {
      // console.log('COMMAND ERROR! Command is "undefined".');
      return;
    }
    // console.log('COMMAND: ' + JSON.stringify(command));
    // console.log('COMMAND: ' + command);
    // console.log('COMMAND TYPE: ' + typeof command);
    let argArray;
    if (typeof args === 'undefined') {
      argArray = [];
    } else if (Array.isArray(args)) {
      argArray = args;
    } else {
      argArray = [args];
    }
    // if (typeof command === 'function') {
    if (Platform.OS === 'ios') {
      // iOS
      command.apply(
        this,
        [this.nodeHandle(), ...argArray],
      );
    } else {
      // Android
      UIManager.dispatchViewManagerCommand(
        this.nodeHandle(),
        command,
        argArray,
      );
    }
  }
}
export default NativeComponent;
