//
//  GSScanditPickerView.m
//  SGScandit
//
//  Created by Boris Conforty on 22.05.17.
//  Copyright © 2017 Facebook. All rights reserved.
//

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
