//
//  GSScanditPickerView.h
//  SGScandit
//
//  Created by Boris Conforty on 22.05.17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>
#import <React/RCTComponent.h>

@interface SGScanditPickerView : UIView

@property (nonatomic, copy) NSDictionary *settings;
@property (nonatomic, strong) SBSBarcodePicker *picker;

@property (nonatomic, copy) RCTDirectEventBlock onDidScan;
@property (nonatomic, copy) RCTDirectEventBlock onSettingsDidChange;

@end
