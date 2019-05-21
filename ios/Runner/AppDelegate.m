#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSString *configPath = [[NSBundle mainBundle] pathForResource:@"assets/config.json" ofType:nil];
  NSData *data = [[NSFileManager defaultManager] contentsAtPath:configPath];
  NSDictionary *config = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
  NSString *geocodingKey = [config valueForKeyPath:@"geocodingKey"];

  [GMSServices provideAPIKey:geocodingKey];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
