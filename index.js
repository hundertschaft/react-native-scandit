/* @flow */

/* eslint
  no-underscore-dangle:
    ["error", { "allow": ["_onDidScan", "_onSettingsDidChange", "_activity"] }]
  no-console:
    0
*/

import React, { PropTypes } from 'react';
import {
  NativeModules,
  Platform,
  requireNativeComponent,
  UIManager,
  View,
  Event,
} from 'react-native';

import NativeComponent from './SGNativeComponent';

import type {
  ScanditPointType as PointType,
  ScanditSizeType as SizeType,
  ScanditRectType as RectType,
  ScanditScanAreaType as ScanAreaType,
  ScanditSymbologyType as SymbologyType,
  ScanditSettingsType as SettingsType,
} from './SGScanditTypes';

const { SGScandit, SGScanditPicker } = NativeModules;

const iOS = Platform.OS === 'ios';

const Commands = iOS
  ? SGScanditPicker
  : UIManager.SGScanditPicker.Commands;

type ScanditPickerPropsType = {

}

type ScanditPickerActivityType = 'active' | 'paused' | 'stopped';

export class ScanditPicker extends NativeComponent {
  _onDidScan: Function;
  _onSettingsDidChange: Function;
  _activity: ScanditPickerActivityType;

  constructor(props: ScanditPickerPropsType) {
    super(props);

    this._onDidScan = this._onDidScan.bind(this);
    this._onSettingsDidChange = this._onSettingsDidChange.bind(this);
    this._activity = 'stopped';
  }

  _onDidScan(event: Event) {
    if (this.props.onScan) {
      this.props.onScan(event.nativeEvent);
    }
    if (this.props.onCodeScan) {
      const codes = event.nativeEvent.newlyRecognizedCodes;
      if (codes && codes.length) {
        this.props.onCodeScan(codes[0]);
      }
    }
  }

  _onSettingsDidChange(event: Event) {
    if (!this.props.onSettingsChange) {
      return;
    }
    console.log(JSON.stringify(event.nativeEvent, null, 2));
    this.props.onSettingsChange(event.nativeEvent);
  }

  componentDidMount() {
    this.startScanning();
  }

  getSettings(): Promise<*> {
    return this.dispatchCommand(Commands.getSettings);
  }

  setSettings(settings: SettingsType): Promise<*> {
    return this.dispatchCommand(Commands.setSettings, [settings]);
  }

  startScanning(): Promise<*> {
    return this.dispatchCommand(Commands.startScanning);
  }

  startScanningInPausedState() {
    this.dispatchCommand(Commands.startScanningInPausedState);
  }

  stopScanning() {
    this.dispatchCommand(Commands.stopScanning);
  }

  pauseScanning() {
    this.dispatchCommand(Commands.pauseScanning);
  }

  resumeScanning() {
    this.dispatchCommand(Commands.resumeScanning);
  }

  activity(): string {
    return this._activity;
  }

  render() {
    return (<SGScanditPickerComponent
      {...this.props}
      onDidScan={this._onDidScan}
      onSettingsDidChange={this._onSettingsDidChange}
    />);
  }
}

ScanditPicker.propTypes = {
  settings: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  onScan: PropTypes.func,
  onCodeScan: PropTypes.func,
  onSettingsChange: PropTypes.func,
  ...View.propTypes,
};

const SGScanditPickerComponent = requireNativeComponent(
  'SGScanditPicker',
  ScanditPicker,
  {
    nativeOnly: {
      onDidScan: true,
      onSettingsDidChange: true,
    },
  },
);

export default SGScandit;

export type ScanditPointType = PointType;
export type ScanditSizeType = SizeType;
export type ScanditRectType = RectType;
export type ScanditScanAreaType = ScanAreaType;
export type ScanditSymbologyType = SymbologyType;
export type ScanditSettingsType = SettingsType;
export const ScanditSDKVersion = SGScandit.SDK_VERSION;
