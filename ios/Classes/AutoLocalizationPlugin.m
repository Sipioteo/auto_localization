#import "AutoLocalizationPlugin.h"
#import <auto_localization/auto_localization-Swift.h>

@implementation AutoLocalizationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAutoLocalizationPlugin registerWithRegistrar:registrar];
}
@end
