//
//  SGScanditPicker.m
//
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

RCT_EXPORT_METHOD(startScanning:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self startScanningInPausedState:reactTag
                              paused:NO
                            resolver:resolve
                            rejecter:reject];
}

RCT_EXPORT_METHOD(startScanningInPausedState:(nonnull NSNumber *)reactTag
                  paused:(BOOL)paused
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         [_view.picker startScanningInPausedState:paused
                                completionHandler:^
          {
              if (_view.picker.isScanning) {
                  resolve(@"Scan started");
              } else {
                  NSError *error = [NSError errorWithDomain:@"world" code:-1 userInfo:nil];
                  reject(@"-1", @"Could not start scanning", error);
              }
          }];
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

RCT_EXPORT_METHOD(getSettings:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         resolve(_view.settings);
         if (_view.onSettingsDidChange) {
             _view.onSettingsDidChange(_view.settings);
         }
     }];
}

RCT_EXPORT_METHOD(setSettings:(nonnull NSNumber *)reactTag
                  settings:(NSDictionary *)settings
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self callBlockIfViewIsMine:reactTag
                          block:
     ^{
         if (settings) {
             _view.settings = settings;
             resolve(_view.settings);
         } else {
             NSError *error = [NSError errorWithDomain:@"world" code:-1 userInfo:nil];
             reject(@"-1", @"Cannot set null settings", error);
         }
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
