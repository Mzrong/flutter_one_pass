#import "FlutterOnePassPlugin.h"
#if __has_include(<flutter_one_pass/flutter_one_pass-Swift.h>)
#import <flutter_one_pass/flutter_one_pass-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_one_pass-Swift.h"
#endif

#import <OneLoginSDK/OneLoginSDK.h>

@implementation FlutterOnePassPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterOnePassPlugin registerWithRegistrar:registrar];
}
@end
