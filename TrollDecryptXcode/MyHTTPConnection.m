#import "MyHTTPConnection.h"
#import "MyJsonResponse.h"
#import "TDUtils.h"
#import "server/HTTPAsyncFileResponse.h"
#import "server/HTTPMessage.h"

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    return YES; // 支持所有方法
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    if ([method isEqualToString:@"POST"]) {
        return YES;
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (void)processBodyData:(NSData *)postDataChunk {
    [request appendData:postDataChunk];
}

- (NSObject <HTTPResponse> *)dumpAppMethod:(NSDictionary *)data {
    NSString *bundle_id = data[@"bundle_id"];
    if (!bundle_id || [bundle_id length] == 0) {
        return [self fail:@"bundle_id 非法"];
    }

    NSArray *apps = appList();

    // 定义搜索的键值对
    NSString *bundle_key = @"bundleID";
    NSString *bundle_id_value = bundle_id;

    // 使用谓词进行搜索
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", bundle_key, bundle_id_value];
    NSArray *filteredApps = [apps filteredArrayUsingPredicate:predicate];

    if (filteredApps.count > 0) {
        NSDictionary *app = filteredApps[0];
        decryptApp(app);
        NSString *name = app[@"name"];
        NSString *version = app[@"version"];
        NSString *executable = app[@"executable"];
        NSDictionary *json = @{
                @"bundle_id": bundle_id_value,
                @"name": name,
                @"version": version,
                @"executable": executable
        };
        return [self ok:json];
    } else {
        return [self fail:@"应用不在"];
    }
}

- (NSObject <HTTPResponse> *)fileDownload:(NSString *)filePath {
    HTTPAsyncFileResponse *response = [[HTTPAsyncFileResponse alloc] initWithFilePath:filePath forConnection:self];
    return response;
}

- (NSObject <HTTPResponse> *)queryAppList {
    NSArray *apps = appList();
    return [self ok:apps];
}

- (NSObject <HTTPResponse> *)queryAppInfo:(NSString *)bundle_id {
    NSArray *apps = appList();
    // 定义搜索的键值对
    NSString *bundle_key = @"bundleID";
    NSString *bundle_id_value = bundle_id;

    // 使用谓词进行搜索
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", bundle_key, bundle_id_value];
    NSArray *filteredApps = [apps filteredArrayUsingPredicate:predicate];

    if ([filteredApps count] > 0) {
        NSDictionary *app = filteredApps[0];
        NSString *name = app[@"name"];
        NSString *version = app[@"version"];
        NSString *executable = app[@"executable"];
        NSDictionary *json = @{@"bundle_id": bundle_id_value, @"name": name, @"version": version, @"executable": executable};
        return [self ok:json];
    }
    return [self fail:@"应用不存在"];
}

- (NSObject <HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)urlPath {

    NSURL *url = [NSURL URLWithString:urlPath];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;

    if ([method isEqualToString:@"GET"] && [[url path] isEqualToString:@"/app/list"]) {
        return [self queryAppList];
    } else if ([method isEqualToString:@"GET"] && [[url path] isEqualToString:@"/app/info"]) {
        NSString *bundle_id;
        for (NSURLQueryItem *item in queryItems) {
            if ([[item name] isEqualToString:@"bundle_id"]) {
                bundle_id = item.value;
                break;
            }
        }
        if (!bundle_id) {
            return [self fail:@"缺少bundle_id参数"];
        }
        if ([bundle_id length] == 0) {
            return [self fail:@"bundle_id不能为空"];
        }
        return [self queryAppInfo:bundle_id];
    } else if ([method isEqualToString:@"POST"] && [[url path] isEqualToString:@"/app/dump"]) {
        NSData *body = request.body;
        NSError *error;
        NSString *body_str = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableContainers error:&error];
        if (error) {
//            [self dialog:[NSString stringWithFormat:@"请求参数非法：body_str：%@", body_str]];
            return [self fail:[NSString stringWithFormat:@"请求参数非法：JSON解析失败：%@ -> %@", error, body_str]];
        }
        return [self dumpAppMethod:data];
    } else if ([method isEqualToString:@"GET"] && [[url path] isEqualToString:@"/file/download"]) {
        NSString *filePath;
        for (NSURLQueryItem *item in queryItems) {
            if ([[item name] isEqualToString:@"path"]) {
                filePath = item.value;
            }
        }
        if (!filePath) {
            return [self fail:@"缺少path参数"];
        }
        return [self fileDownload:filePath];
    }

    return [self apis];
}

- (NSObject <HTTPResponse> *)apis {
    NSDictionary *data = @{
            @"/app/list": @{
                    @"des": @"获取应用列表"
            },
            @"/app/info": @{
                    @"des": @"查询app信息",
                    @"query": @{
                            @"bundle_id": @"应用标识"
                    }
            },
            @"/app/dump": @{
                    @"des": @"砸壳",
                    @"json": @{
                            @"bundle_id": @"应用标识"
                    }
            },
            @"/file/download": @{
                    @"des": @"文件下载",
                    @"query": @{
                            @"path": @"文件绝对路径"
                    }
            }
    };
    return [self ok:data];
}

- (NSObject <HTTPResponse> *)fail:(NSString *)msg {
    NSDictionary *data = @{@"ok": @NO, @"msg": msg};
    NSData *resp = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingSortedKeys error:nil];
    MyJsonResponse *json = [[MyJsonResponse alloc] initWithData:resp];
    return json;
}

- (NSObject <HTTPResponse> *)ok:(id <NSObject>)data {
    NSDictionary *wrap_data = @{@"ok": @YES, @"data": data};
    NSData *resp = [NSJSONSerialization dataWithJSONObject:wrap_data options:NSJSONWritingSortedKeys error:nil];
    MyJsonResponse *json = [[MyJsonResponse alloc] initWithData:resp];
    return json;
}

- (void)dialog:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [UIViewController new];
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        [alertWindow makeKeyAndVisible];
        UIWindow *kw = alertWindow;
        UIViewController *root;
        if ([kw respondsToSelector:@selector(topmostPresentedViewController)]) {
            root = [kw performSelector:@selector(topmostPresentedViewController)];
        } else {
            root = [kw rootViewController];
        }
        root.modalPresentationStyle = UIModalPresentationFullScreen;
        UIAlertController *alertController = [UIAlertController
                alertControllerWithTitle:@"Decrypting"
                                 message:msg
                          preferredStyle:UIAlertControllerStyleAlert];
        root.modalPresentationStyle = UIModalPresentationFullScreen;
        [root presentViewController:alertController animated:YES completion:nil];
    });
}

@end
