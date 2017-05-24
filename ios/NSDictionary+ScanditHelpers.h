//
//  NSDictionary+ScanditHelpers.h
//
//  Created by Boris Conforty on 04.05.17.
//  Copyright © 2017 Salathé Group, EPFL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

@interface NSDictionary (ScanditHelpers)

+ (NSDictionary *)dictionaryWithPropertiesOfObject:(id)obj;
+ (NSDictionary *)dictionaryWithQuadrilateral:(SBSQuadrilateral)quadrilateral;

@end
