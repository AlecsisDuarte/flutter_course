#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#import <Flutter/Flutter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSString *configPath =
      [[NSBundle mainBundle] pathForResource:@"assets/config.json" ofType:nil];
  NSData *data = [[NSFileManager defaultManager] contentsAtPath:configPath];
  NSDictionary *config =
      [NSJSONSerialization JSONObjectWithData:data
                                      options:NSJSONReadingAllowFragments
                                        error:nil];
  NSString *geocodingKey = [config valueForKeyPath:@"geocodingKey"];

  FlutterViewController *controller =
      (FlutterViewController *)self.window.rootViewController;
  FlutterMethodChannel *batteryChannel =
      [FlutterMethodChannel methodChannelWithName:@"flutter-course.com/battery"
                                  binaryMessenger:controller];
  [batteryChannel
      setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"getBatteryPercentage" isEqualToString:call.method]) {
          int batteryPercentage = [self getBatteryPercentage];
          if (batteryPercentage == -1) {
            result([FlutterError errorWithCode:@"-1"
                                       message:"Couldn't fetch battery level"
                                       details:nil])
          } else {
            result(@(batteryPercentage));
          }
        } else {
          result(FlutterMethodNotImplemented);
        }
      }];

  [GMSServices provideAPIKey:geocodingKey];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application
      didFinishLaunchingWithOptions:launchOptions];
}

- (int)getBatteryPercentage {
  UIDevice *device = UIDevice.currentDevice;
  device.batteryMonitoringEnabled = YES;
  if (device.batteryState == UIDeviceBatteryStateUnknown) {
    return -1;
  } else {
    return (int)(device.batteryLevel) * 100;
  }
}

@end
