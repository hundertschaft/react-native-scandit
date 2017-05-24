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

import NativeComponent from './SGNativeComponent'

import type {
  ScanditPointType as PointType,
  ScanditSizeType as SizeType,
  ScanditRectType as RectType,
  ScanditQuadrilateralType as QuadrilateralType,
  ScanditSymbologyType as SymbologyType,
  ScanditSettingsType as SettingsType,
} from './SGScanditTypes'

const { SGScandit, SGScanditPicker } = NativeModules;

const iOS = Platform.OS === 'ios';

const Commands = iOS
  ? SGScanditPicker
  : UIManager.SGScanditPicker.Commands;

type ScanditPickerPropsType = {

}

export class ScanditPicker extends NativeComponent {
  _onDidScan: Function;
  _onSettingsDidChange: Function;

  _autoTimeouts: number[];

  constructor(props: ScanditPickerPropsType) {
    super(props);

    this._autoTimeouts = [];
    this._onDidScan = this._onDidScan.bind(this);
    this._onSettingsDidChange = this._onSettingsDidChange.bind(this);
  }

  _removeAutoTimeouts() {
    this._autoTimeouts.forEach((timeout) => {
      clearTimeout(timeout);
    });
    this._autoTimeouts = [];
  }

  _stopAndRestart() {
    this.stopScanning();
    const t1 = setTimeout(() => {
      this.startScanningInPausedState();
    }, 750);
    const t2 = setTimeout(() => {
      this.startScanning();
    }, 1500);

    this._autoTimeouts.push(t1);
    this._autoTimeouts.push(t2);
  }

  _onDidScan(event: Event) {
    this._stopAndRestart();

    if (this.props.onScan) {
      this.props.onScan(event.nativeEvent);
    }
  }

  _onSettingsDidChange(event: Event) {
    if (!this.props.onSettingsChange) {
      return;
    }
    this.props.onSettingsChange(event.nativeEvent);
  }

  componentDidMount() {
    this.startScanning();
  }

  getSettings() {
    this.dispatchCommand(Commands.getSettings);
  }

  setSettings(settings: SettingsType) {
    this.dispatchCommand(Commands.setSettings, [settings]);
  }
  startScanning() {
    this.dispatchCommand(Commands.startScanning);
  }

  startScanningInPausedState() {
    this.dispatchCommand(Commands.startScanningInPausedState);
  }

  stopScanning() {
    this.dispatchCommand(Commands.stopScanning);
    this._removeAutoTimeouts();
  }

  pauseScanning() {
    this.dispatchCommand(Commands.pauseScanning);
    this._removeAutoTimeouts();
  }

  resumeScanning() {
    this.dispatchCommand(Commands.resumeScanning);
  }

  render() {
    return <SGScanditPickerComponent {...this.props}
      onDidScan={this._onDidScan}
      onSettingsDidChange={this._onSettingsDidChange}
    />;
  }
}

ScanditPicker.propTypes = {
  settings: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  onScan: PropTypes.func,
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
    }
  },
);

export default SGScandit;

export type ScanditPointType = PointType;
export type ScanditSizeType = SizeType;
export type ScanditRectType = RectType;
export type ScanditQuadrilateralType = QuadrilateralType;
export type ScanditSymbologyType = SymbologyType;
export type ScanditSettingsType = SettingsType;
