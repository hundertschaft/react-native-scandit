//
//  ScanditPicker.m
//  SGScandit
//
//  Created by Boris Conforty on 22.05.17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "SGScanditPicker.h"
#import "SGScanditPickerView.h"

#import <React/RCTUIManager.h>

#import "NSDictionary+ScanditHelpers.h"

@interface SGScanditPicker()<SBSScanDelegate>

@end

@implementation SGScanditPicker
{
    SGScanditPickerView *_view;
}

RCT_EXPORT_MODULE()

typedef void (^CallbackBlock)(void);

- (void)callBlockIfViewIsMine:(nonnull NSNumber *)reactTag
                        block:(CallbackBlock)block
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        if ([reactTag isEqualToNumber:_view.reactTag]) {
            block();
        }
        /*UIView *view = viewRegistry[reactTag];
        if (view == _view) {
            block();
        }*/
    }];
}

RCT_EXPORT_METHOD(startScanning:(nonnull NSNumber *)reactTag)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         [_view.picker startScanning];
     }];
}

RCT_EXPORT_METHOD(startScanningInPausedState:(nonnull NSNumber *)reactTag)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         [_view.picker startScanningInPausedState:YES];
     }];
}

RCT_EXPORT_METHOD(stopScanning:(nonnull NSNumber *)reactTag)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         [_view.picker stopScanning];
     }];
}

RCT_EXPORT_METHOD(pauseScanning:(nonnull NSNumber *)reactTag)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         [_view.picker pauseScanning];
     }];
}

RCT_EXPORT_METHOD(resumeScanning:(nonnull NSNumber *)reactTag)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         [_view.picker resumeScanning];
     }];
}


RCT_EXPORT_VIEW_PROPERTY(settings, NSDictionary *)

RCT_EXPORT_METHOD(getSettings:(nonnull NSNumber *)reactTag)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         if (_view.onSettingsDidChange) {
             _view.onSettingsDidChange(_view.settings);
         }
     }];
}

RCT_EXPORT_METHOD(setSettings:(nonnull NSNumber *)reactTag
                  settings:(NSDictionary *)settings)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         _view.settings = settings;
         /*
         [[NSNotificationCenter defaultCenter] postNotificationName:GET_SETTINGS_EVENT_NAME
                                                             object:self
                                                           userInfo:settings];
          */
     }];
}

RCT_EXPORT_VIEW_PROPERTY(onDidScan, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSettingsDidChange, RCTDirectEventBlock)

- (UIView *)view
{
    _view = [SGScanditPickerView new];
    _view.picker.scanDelegate = self;
    return _view;
}

- (void)barcodePicker:(SBSBarcodePicker *)picker didScan:(SBSScanSession *)session
{
    if (_view.onDidScan) {
        NSDictionary *body = [NSDictionary dictionaryWithPropertiesOfObject:session];
        _view.onDidScan(body);
    }
}

@end
