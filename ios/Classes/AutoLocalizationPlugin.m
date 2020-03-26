#import "AutoLocalizationPlugin.h"
#if __has_include(<auto_localization/auto_localization-Swift.h>)
#import <auto_localization/auto_localization-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "auto_localization-Swift.h"
#endif

@implementation AutoLocalizationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAutoLocalizationPlugin registerWithRegistrar:registrar];
}
@end
