//
//  SBSScanSettings+Helpers.m
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

#import "SBSScanSettings+Helpers.h"

@implementation SBSScanSettings (Helpers)

NSString *symbologyToString(SBSSymbology symbology)
{
    NSString *string = nil;
    // Use switch without default instead of a dictionary, for instance, to get
    // compiler warning if we miss an item
    switch (symbology) {
        case SBSSymbologyEAN13:              string = @"EAN13"; break;
        case SBSSymbologyUPC12:              string = @"UPC12"; break;
        case SBSSymbologyUPCE:               string = @"UPCE"; break;
        case SBSSymbologyCode39:             string = @"Code39"; break;
        case SBSSymbologyPDF417:             string = @"PDF417"; break;
        case SBSSymbologyDatamatrix:         string = @"Datamatrix"; break;
        case SBSSymbologyQR:                 string = @"QR"; break;
        case SBSSymbologyITF:                string = @"ITF"; break;
        case SBSSymbologyCode128:            string = @"Code128"; break;
        case SBSSymbologyCode93:             string = @"Code93"; break;
        case SBSSymbologyMSIPlessey:         string = @"MSIPlessey"; break;
        case SBSSymbologyGS1Databar:         string = @"GS1Databar"; break;
        case SBSSymbologyGS1DatabarExpanded: string = @"GS1DatabarExpanded"; break;
        case SBSSymbologyCodabar:            string = @"Codabar"; break;
        case SBSSymbologyEAN8:               string = @"EAN8"; break;
        case SBSSymbologyAztec:              string = @"Aztec"; break;
        case SBSSymbologyTwoDigitAddOn:      string = @"TwoDigitAddOn"; break;
        case SBSSymbologyFiveDigitAddOn:     string = @"FiveDigitAddOn"; break;
        case SBSSymbologyCode11:             string = @"Code11"; break;
        case SBSSymbologyMaxiCode:           string = @"MaxiCode"; break;
        case SBSSymbologyGS1DatabarLimited:  string = @"GS1DatabarLimited"; break;
        case SBSSymbologyCode25:             string = @"Code25"; break;
        case SBSSymbologyMicroPDF417:        string = @"MicroPDF417"; break;
        case SBSSymbologyRM4SCC:             string = @"RM4SCC"; break;
        case SBSSymbologyKIX:                string = @"KIX"; break;
        case SBSSymbologyUnknown:            string = @"unknown"; break;
    }
    if (!string) string = @"unknown";

    return string;
}

inline void addToReversedDictionary(NSMutableDictionary *dict, SBSSymbology symbology)
{
    dict[[symbologyToString(symbology) lowercaseString]] = @(symbology);
}

SBSSymbology stringToSymbology(NSString *string)
{
    static NSMutableDictionary *reversedSymbols;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reversedSymbols = [[NSMutableDictionary alloc] initWithCapacity:32];
#define ADDSYMBOLOGY(symbology) reversedSymbols[[symbologyToString(symbology) lowercaseString]] = @(symbology);
        ADDSYMBOLOGY(SBSSymbologyEAN13);
        ADDSYMBOLOGY(SBSSymbologyUPC12);
        ADDSYMBOLOGY(SBSSymbologyUPCE);
        ADDSYMBOLOGY(SBSSymbologyCode39);
        ADDSYMBOLOGY(SBSSymbologyPDF417);
        ADDSYMBOLOGY(SBSSymbologyDatamatrix);
        ADDSYMBOLOGY(SBSSymbologyQR);
        ADDSYMBOLOGY(SBSSymbologyITF);
        ADDSYMBOLOGY(SBSSymbologyCode128);
        ADDSYMBOLOGY(SBSSymbologyCode93);
        ADDSYMBOLOGY(SBSSymbologyMSIPlessey);
        ADDSYMBOLOGY(SBSSymbologyGS1Databar);
        ADDSYMBOLOGY(SBSSymbologyGS1DatabarExpanded);
        ADDSYMBOLOGY(SBSSymbologyCodabar);
        ADDSYMBOLOGY(SBSSymbologyEAN8);
        ADDSYMBOLOGY(SBSSymbologyAztec);
        ADDSYMBOLOGY(SBSSymbologyTwoDigitAddOn);
        ADDSYMBOLOGY(SBSSymbologyFiveDigitAddOn);
        ADDSYMBOLOGY(SBSSymbologyCode11);
        ADDSYMBOLOGY(SBSSymbologyMaxiCode);
        ADDSYMBOLOGY(SBSSymbologyGS1DatabarLimited);
        ADDSYMBOLOGY(SBSSymbologyCode25);
        ADDSYMBOLOGY(SBSSymbologyMicroPDF417);
        ADDSYMBOLOGY(SBSSymbologyRM4SCC);
        ADDSYMBOLOGY(SBSSymbologyKIX);
    });

    return [reversedSymbols[[string lowercaseString]] integerValue];
}

static NSDictionary *NSDictionaryFromCGPoint(CGPoint point)
{
    return @{@"x": @(point.x),
             @"y": @(point.y)};
}

static NSDictionary *NSDictionaryFromCGRect(CGRect rect)
{
    return @{@"x": @(rect.origin.x),
             @"y": @(rect.origin.y),
             @"width": @(rect.size.width),
             @"height": @(rect.size.height)};
}

#define BOOLTOSTR(val) (val ? @"true" : @"false")

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];

    NSString *string;
    NSMutableArray *array;

    switch (self.workingRange) {
        case SBSWorkingRangeLong:     string = @"long"; break;
        case SBSWorkingRangeStandard: string = @"standard"; break;
        default:                      string = @"unknown";
    }
    dict[@"workingRange"] = string;

    array = [NSMutableArray new];
    [self.enabledSymbologies enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        [array addObject:symbologyToString(obj.integerValue)];
    }];
    dict[@"enabledSymbologies"] = array;

    // Skipped settingsForSymbology

    dict[@"force2dRecognition"] = BOOLTOSTR(self.force2dRecognition);

    dict[@"maxNumberOfCodesPerFrame"] = @(self.maxNumberOfCodesPerFrame);

    dict[@"codeDuplicateFilter"] = @(self.codeDuplicateFilter);

    dict[@"codeCachingDuration"] = @(self.codeCachingDuration);

    dict[@"relativeZoom"] = @(self.relativeZoom);

    switch (self.cameraFacingPreference) {
        case SBSCameraFacingDirectionBack:  string = @"back"; break;
        case SBSCameraFacingDirectionFront: string = @"front"; break;
        default: string = @"unknown";
    }
    dict[@"cameraFacingPreference"] = string;

    dict[@"deviceName"] = self.deviceName;

    dict[@"highDensityModeEnabled"] = BOOLTOSTR(self.highDensityModeEnabled);

    dict[@"activeScanningAreaLandscape"] = NSDictionaryFromCGRect(self.activeScanningAreaLandscape);

    dict[@"activeScanningAreaPortrait"] = NSDictionaryFromCGRect(self.activeScanningAreaPortrait);

    dict[@"restrictedAreaScanningEnabled"] = BOOLTOSTR(self.restrictedAreaScanningEnabled);

    dict[@"scanningHotSpot"] = NSDictionaryFromCGPoint(self.scanningHotSpot);

    dict[@"motionCompensationEnabled"] = BOOLTOSTR(self.motionCompensationEnabled);

    dict[@"codeRejectionEnabled"] = BOOLTOSTR(self.codeRejectionEnabled);

    // Skipped areaSettingsPortrait
    // Skipped areaSettingsLandscape

    dict[@"matrixScanEnabled"] = BOOLTOSTR(self.matrixScanEnabled);

    return dict;
}

inline static BOOL strToBool(NSString *val)
{
    if ([val isEqualToString:@"true"]) return true;
    if ([val isEqualToString:@"false"]) return false;
    NSLog(@"Invalid boolean: %@", val);
    return false;
}

static CGPoint CGPointFromNSDictionary(NSDictionary *dict)
{
    return (CGPoint){
        [dict[@"x"] floatValue],
        [dict[@"y"] floatValue]
    };
}

static CGSize CGSizeFromNSDictionary(NSDictionary *dict)
{
    return (CGSize){
        [dict[@"width"] floatValue],
        [dict[@"height"] floatValue]
    };
}

static CGRect CGRectFromNSDictionary(NSDictionary *dict)
{
    CGPoint origin = CGPointFromNSDictionary(dict);
    CGSize size = CGSizeFromNSDictionary(dict);
    CGRect rect;
    rect.origin = origin;
    rect.size = size;

    return rect;
}

+ (SBSScanSettings *)settingsFromDictionary:(NSDictionary *)dict
{
    /*
     // Automatically get properties
     unsigned int count;
     objc_property_t *properties = class_copyPropertyList([scanditBarcodeSettings class],
     &count);
     for (int i = 0; i<count; i++) {
     const char *propertyName = property_getName(properties[i]);
     NSString *key = [NSString stringWithUTF8String:propertyName];
     NSLog(@"KEY: %@", key);
     id value = [settings objectForKey:key];
     if (value) {
     [scanditBarcodeSettings setValue:value
     forKey:key];
     }
     }
     free(properties);
     */
    SBSScanSettings *settings = [SBSScanSettings defaultSettings];

    NSString *string;

    string = dict[@"workingRange"];
    if (string) {
        settings.workingRange = [
                                 @{
                                   @"long": @(SBSWorkingRangeLong),
                                   @"standard": @(SBSWorkingRangeStandard),
                                   }[string] integerValue];
    }

    NSArray *symbologies = dict[@"enabledSymbologies"];
    if (symbologies) {
        for (int i = 0; i < symbologies.count; i++) {
            NSString *symbologyString = symbologies[i];
            SBSSymbology symbology = stringToSymbology(symbologyString);

            if (symbology == SBSSymbologyUnknown) {
                NSLog(@"UNRECOGNIZED SYMBOLOGY: %@", symbologyString);
                continue;
            }

            [settings setSymbology:symbology
                           enabled:YES];
        }
    }

    // Skipped settingsForSymbology
#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)
    id value;
#define GETBOOLPROP(name) if ((value = [dict objectForKey:NSStringize(name)])) settings.name = strToBool(value)
#define GETINTPROP(name) if ((value = [dict objectForKey:NSStringize(name)])) settings.name = [value integerValue]
#define GETFLOATPROP(name) if ((value = [dict objectForKey:NSStringize(name)])) settings.name = [value floatValue]
#define GETSTRINGPROP(name) if ((value = [dict objectForKey:NSStringize(name)])) settings.name = value
#define GETRECTPROP(name) if ((value = [dict objectForKey:NSStringize(name)])) settings.name = CGRectFromNSDictionary(value)
#define GETPOINTPROP(name) if ((value = [dict objectForKey:NSStringize(name)])) settings.name = CGPointFromNSDictionary(value)

    GETBOOLPROP(force2dRecognition);
    GETINTPROP(maxNumberOfCodesPerFrame);
    GETINTPROP(codeDuplicateFilter);
    GETINTPROP(codeCachingDuration);
    GETFLOATPROP(relativeZoom);

    string = dict[@"cameraFacingPreference"];
    if (string) {
        settings.cameraFacingPreference = [
                                           @{
                                             @"back": @(SBSCameraFacingDirectionBack),
                                             @"front": @(SBSCameraFacingDirectionFront),
                                             }[string] integerValue];
    }

    GETSTRINGPROP(deviceName);
    GETBOOLPROP(highDensityModeEnabled);
    GETRECTPROP(activeScanningAreaLandscape);
    GETRECTPROP(activeScanningAreaPortrait);
    GETBOOLPROP(restrictedAreaScanningEnabled);
    GETPOINTPROP(scanningHotSpot);
    GETBOOLPROP(motionCompensationEnabled);
    GETBOOLPROP(codeRejectionEnabled);

    // Skipped areaSettingsPortrait
    // Skipped areaSettingsLandscape

    GETBOOLPROP(matrixScanEnabled);

    return settings;
}

@end
