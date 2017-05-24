//
//  SBSScanSettings+Helpers.h
//
//  Created by Boris Conforty on 03.05.17.
//  Copyright © 2017 Salathé Group, EPFL. All rights reserved.
//

#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

NSString *symbologyToString(SBSSymbology symbology);
SBSSymbology stringToSymbology(NSString *string);

@interface SBSScanSettings (Helpers)

- (NSDictionary *)toDictionary;
+ (SBSScanSettings *)settingsFromDictionary:(NSDictionary *)dict;

@end
