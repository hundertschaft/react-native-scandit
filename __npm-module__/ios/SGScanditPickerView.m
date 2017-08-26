//
//  SGScanditPickerView.m
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

#import "SGScanditPickerView.h"
#import "SBSScanSettings+Helpers.h"

@implementation SGScanditPickerView
{
    SBSScanSettings *_scanSettings;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scanSettings = [SBSScanSettings defaultSettings];
        _picker = [[SBSBarcodePicker alloc] initWithSettings:_scanSettings];
        _picker.view.frame = self.bounds;
        _picker.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_picker.view];
    }
    return self;
}

- (NSDictionary *)settings
{
    return [_scanSettings toDictionary];
}

- (void)setSettings:(NSDictionary *)settings
{
    NSMutableDictionary *newSettings = [_scanSettings toDictionary].mutableCopy;

    for (NSString *key in settings.allKeys) {
        [newSettings setValue:settings[key] forKey:key];
    }

    _scanSettings = [SBSScanSettings settingsFromDictionary:newSettings];
    [_picker applyScanSettings:_scanSettings completionHandler:nil];

    if (_onSettingsDidChange) {
        _onSettingsDidChange(self.settings);
    }
}


@end
