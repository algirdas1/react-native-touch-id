#import "TouchID.h"
#import <React/RCTUtils.h>
#import "React/RCTConvert.h"

int RCTTouchIDNotSupported = 100;

@implementation TouchID

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSDictionary *)constantsToExport
{
    NSMutableDictionary * dict = [@{ @"LAErrorAuthenticationFailed": @(LAErrorAuthenticationFailed),
                             @"LAErrorUserCancel": @(LAErrorUserCancel),
                             @"LAErrorUserFallback": @(LAErrorUserFallback),
                             @"LAErrorSystemCancel": @(LAErrorSystemCancel),
                             @"LAErrorPasscodeNotSet": @(LAErrorPasscodeNotSet),
                             @"LAErrorAppCancel": @(LAErrorAppCancel),
                             @"LAErrorInvalidContext": @(LAErrorInvalidContext),
                             @"LAErrorNotInteractive": @(LAErrorNotInteractive),
                                     @"RCTTouchIDNotSupported": @(RCTTouchIDNotSupported)
                             } mutableCopy];
    
    if (@available(iOS 11.0, *)) {
        [dict addEntriesFromDictionary:@{
                                        @"LAErrorBiometryNotAvailable": @(LAErrorBiometryNotAvailable),
                                        @"LAErrorBiometryNotEnrolled": @(LAErrorBiometryNotEnrolled),
                                        @"LAErrorBiometryLockout": @(LAErrorBiometryLockout),
                                        }];
    } else {
        [dict addEntriesFromDictionary:@{
                                        @"LAErrorBiometryNotAvailable": @(LAErrorTouchIDNotAvailable),
                                        @"LAErrorBiometryNotEnrolled": @(LAErrorTouchIDNotEnrolled),
                                        @"LAErrorBiometryLockout": @(LAErrorTouchIDLockout),
                                        }];
    }
    return dict;
}

RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(isSupported: (RCTResponseSenderBlock)callback)
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        callback(@[[NSNull null], [self getBiometryType:context]]);
        // Device does not support TouchID
    } else {
        callback(@[RCTMakeError(@"RCTTouchIDNotSupported", nil, nil)]);
        return;
    }
}

RCT_EXPORT_METHOD(authenticate: (NSString *)reason
                  options:(NSDictionary *)options
                  callback: (RCTResponseSenderBlock)callback)
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    
    if (RCTNilIfNull([options objectForKey:@"fallbackLabel"]) != nil) {
        NSString *fallbackLabel = [RCTConvert NSString:options[@"fallbackLabel"]];
        context.localizedFallbackTitle = fallbackLabel;
    } else {
        context.localizedFallbackTitle = @"";
    }
    
    // Device has TouchID
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        // Attempt Authentification
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:reason
                          reply:^(BOOL success, NSError *error)
         {
             if (success) { // Authentication Successful
                 callback(@[[NSNull null], @"Authenticated with Touch ID."]);
             } else if (error) { // Authentication Error
                 callback(@[RCTMakeError(error.description, nil, @{ @"code": @(error.code) })]);
             } else { // Authentication Failure
                 callback(@[RCTMakeError(@"failed", nil, @{ @"code": @(LAErrorAuthenticationFailed) })]);
             }
         }];
        // Device does not support TouchID
    } else {
        callback(@[RCTMakeError(@"RCTTouchIDNotSupported", nil,  @{ @"code": @(RCTTouchIDNotSupported) })]);
        return;
    }
}

- (NSString *)getBiometryType:(LAContext *)context
{
    if (@available(iOS 11, *)) {
        return (context.biometryType == LABiometryTypeFaceID) ? @"FaceID" : @"TouchID";
    }
    
    return @"TouchID";
}

@end


