
#import "SGScandit.h"
#import <ScanditBarcodeScanner/ScanditBarcodeScanner.h>

@implementation SGScandit
{
    RCTResponseSenderBlock _resolve;
    RCTResponseErrorBlock _reject;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(testExportMethod:(NSString *)param)
{
    NSLog(@"Received %@", param);
}

RCT_REMAP_METHOD(testRemapMethodWithPromise,
                 test:(NSString *)string
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"testRemapMethodWithPromise");
    if (string) {
        resolve([string uppercaseString]);
    } else {
        NSError *error = [NSError errorWithDomain:@"world" code:-1 userInfo:nil];
        reject(@"-1", @"Promise rejected, method requires a string", error);
    }
}

RCT_EXPORT_METHOD(testExportMethodWithPromise:(NSString *)string
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"testExportMethodWithPromise");
    if (string) {
        resolve([string uppercaseString]);
    } else {
        NSError *error = [NSError errorWithDomain:@"world" code:-1 userInfo:nil];
        reject(@"-1", @"Promise rejected, method requires a string", error);
    }
}

RCT_EXPORT_METHOD(testExportMethodWithResponse:(NSString *)string
                  resolver:(RCTResponseSenderBlock)resolve
                  rejecter:(RCTResponseErrorBlock)reject)
{
    NSLog(@"testExportMethodWithResponse");
    if (string) {
        resolve(@[[string uppercaseString]]);
    } else {
        NSError *error = [NSError errorWithDomain:@"world" code:-1 userInfo:nil];
        reject(error);
    }
}

RCT_EXPORT_METHOD(setGlobalResolverRejecter:(RCTResponseSenderBlock)resolve
                  rejecter:(RCTResponseErrorBlock)reject)
{
    NSLog(@"setGlobalResolverRejecter");
    _resolve = resolve;
    _reject = reject;
}


RCT_EXPORT_METHOD(testGlobalResolverRejecter:(NSString *)string)
{
    [self testExportMethodWithResponse:string resolver:_resolve rejecter:_reject];
}

#pragma mark - END OF TESTS

RCT_EXPORT_METHOD(setAppKey:(NSString *)key)
{
    [SBSLicense setAppKey:key];
    NSLog(@"Scandit Licence - App key set");
}

- (NSDictionary *)constantsToExport
{
    NSString *sdk_version = [NSString stringWithUTF8String:(const char*)ScanditBarcodeScannerVersionString];
    return @{
             @"SDK_VERSION": sdk_version
             };
}


@end
  
