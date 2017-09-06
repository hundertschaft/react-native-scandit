/*
   Copyright 2017 Salathé Lab - EPFL - Boris Conforty

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/* @flow */

export type ScanditPointType = {
  x: number,
  y: number,
}

export type ScanditSizeType = {
  width: number,
  height: number,
}

export type ScanditRectType = {
  x: number,
  y: number,
  width: number,
  height: number,
}

export type ScanditScanAreaType = {
  // TODO:
}

export type ScanditSymbologyType = 'EAN13' | 'UPC12' | 'UPCE' | 'Code39' | 'PDF417' | 'Datamatrix' | 'QR' | 'ITF' | 'Code128' | 'Code93' | 'MSIPlessey' | 'GS1Databar' | 'GS1DatabarExpanded' | 'Codabar' | 'EAN8' | 'Aztec' | 'TwoDigitAddOn' | 'FiveDigitAddOn' | 'Code11' | 'MaxiCode' | 'GS1DatabarLimited' | 'Code25' | 'MicroPDF417' | 'RM4SCC' | 'KIX'

export type ScanditSettingsType = {
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
