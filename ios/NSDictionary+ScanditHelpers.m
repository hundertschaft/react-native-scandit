//
//  NSDictionary+ScanditHelpers.m
//
//  Created by Boris Conforty on 04.05.17.
//  Copyright © 2017 Salathé Group, EPFL. All rights reserved.
//

#import "NSDictionary+ScanditHelpers.h"

#import <objc/runtime.h>

@implementation NSDictionary (ScanditHelpers)

+ (NSDictionary *)dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        id value, targetValue;
        @try {
            value = [obj valueForKey:key];
        } @catch (NSException *exception) {
            [dict setObject:@"<ERROR>" forKey:key];
            continue;
        }
        
        //if (value) dict[[key stringByAppendingString:@"_class"]] = NSStringFromClass([value class]) ?: @"nil";
        
        if ([value isKindOfClass:[NSString class]]) {
            targetValue = value;
            
        } else if ([value isKindOfClass:[NSNumber class]]) {
            targetValue = value;
            
        } else if ([value isKindOfClass:[NSData class]]) {
            targetValue = [NSString stringWithFormat:@"%@", value];
            
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *orig_list = value;
            NSMutableArray *new_list = [[NSMutableArray alloc] init];
            
            for (int ii = 0; ii < orig_list.count; ii++) {
                NSDictionary *elementDictionary = [self dictionaryWithPropertiesOfObject:orig_list[ii]];
                [new_list addObject:elementDictionary];
            }
            targetValue = new_list;
            
        } else if ([value isKindOfClass:[NSValue class]]) {
            NSValue *nsvalue = value;
            
            const char * typ = [nsvalue objCType];
            
            if (!strcmp(typ, @encode(SBSQuadrilateral))) {
                SBSQuadrilateral loc;
                [nsvalue getValue:&loc];
                targetValue = [NSDictionary dictionaryWithQuadrilateral:loc];
            } else {
                targetValue = [NSString stringWithFormat:@"%@", value];
            }
            
        } else if (value != nil) {
            // Recurse
            targetValue = [self dictionaryWithPropertiesOfObject:value];
            
        } else {
            targetValue = @"";
        }
        
        [dict setObject:targetValue
                 forKey:key];
    }
    
    free(properties);
    return dict;
}

+ (NSDictionary *)dictionaryWithQuadrilateralPoint:(CGPoint)p
{
    return @{
             @"x": @(p.x),
             @"y": @(p.y)
             };
}

+ (NSDictionary *)dictionaryWithQuadrilateral:(SBSQuadrilateral)q
{
    return @{
             @"topLeft"    :[self dictionaryWithQuadrilateralPoint:q.topLeft],
             @"topRight"   :[self dictionaryWithQuadrilateralPoint:q.topRight],
             @"bottomRight":[self dictionaryWithQuadrilateralPoint:q.bottomRight],
             @"bottomLeft" :[self dictionaryWithQuadrilateralPoint:q.bottomLeft],
             };
}

@end
