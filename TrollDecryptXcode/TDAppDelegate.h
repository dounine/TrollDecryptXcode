#import <UIKit/UIKit.h>

@class HTTPServer;
@interface TDAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *rootViewController;
@property (nonatomic, strong) HTTPServer *httpServer;

@end
