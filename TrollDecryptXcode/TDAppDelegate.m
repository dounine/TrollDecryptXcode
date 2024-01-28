#import "http/MyHTTPConnection.h"
#import "TDAppDelegate.h"
#import "TDRootViewController.h"
#import "server/HTTPServer.h"
#import "audio/UnSleep.h"
#import "audio/MMPDeepSleepPreventer.h"

@implementation TDAppDelegate

- (void)runHttpServer {
    NSError *error;
    if (![self.httpServer start:&error]) {
        NSLog(@"http server 启动失败！！！%@", error);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TDRootViewController alloc] init]];
    _window.rootViewController = _rootViewController;

    // 申请后台运行权限
    //    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier backgroundTask;
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{//防止休眠播放音频需要
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    self.httpServer = [HTTPServer new];
    self.httpServer.type = @"_http._tcp.";
    self.httpServer.domain = @"0.0.0.0";
    self.httpServer.port = 6000;
    self.httpServer.connectionClass = [MyHTTPConnection class];

    [self runHttpServer];
//    [[MMPDeepSleepPreventer new] startPreventSleep];//防止休眠
    [[UnSleep new] startPreventSleep:10];//3秒播放一次音乐,防止休眠
    [_window makeKeyAndVisible];
    return YES;
}


@end
