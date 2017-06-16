//
//  NSDictionary+ScanditHelpers.m
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
