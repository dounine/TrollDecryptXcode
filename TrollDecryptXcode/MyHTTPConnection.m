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

    if (self.caches == nil) {
        self.caches = [[NSCache alloc] init];
    }

    if (filteredApps.count > 0) {
        NSUUID *uuid = [[NSUUID alloc] init];
        NSString *process_id = [uuid UUIDString];
        //替换-为""，并转为小写
        process_id = [process_id stringByReplacingOccurrencesOfString:@"-" withString:@""];
        process_id = [process_id lowercaseString];
        NSDictionary *app = filteredApps[0];
        NSMutableDictionary *callback = [NSMutableDictionary dictionary];
        [self.caches setObject:callback forKey:process_id];
        decryptApp(app, callback);
        NSString *name = app[@"name"];
        NSString *version = app[@"version"];
        NSString *executable = app[@"executable"];
        NSDictionary *json = @{
                @"process_id": process_id,
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

- (NSObject <HTTPResponse> *)fileDelete:(NSString *)filePath {
    //判断文件是否存在，存在则删除
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (isExist) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            return [self fail:[NSString stringWithFormat:@"删除文件失败：%@", error]];
        }
        return [self ok:@"删除成功"];
    } else {
        return [self fail:@"文件不存在"];
    }
}

//清空文件夹里面的文件，不要删除文件夹
- (NSObject <HTTPResponse> *)folderClear:(NSString *)filePath {
    //判断文件是否存在，存在则删除
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (isExist) {
        NSError *error;
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
        if (error) {
            return [self fail:[NSString stringWithFormat:@"获取文件夹列表失败：%@", error]];
        }
        NSMutableArray *files = [NSMutableArray array];
        for (NSString *content in contents) {
            NSString *path = [filePath stringByAppendingPathComponent:content];
            [files addObject:path];
            [fileManager removeItemAtPath:path error:&error];
            if (error) {
                return [self fail:[NSString stringWithFormat:@"删除文件失败：%@", error]];
            }
        }
        //返回删除了哪些文件，包含绝对路径
        return [self ok:files];
    } else {
        return [self fail:@"文件夹不存在"];
    }
}

- (NSObject <HTTPResponse> *)queryAppList {
    NSArray *apps = appList();
    return [self ok:apps];
}

- (NSObject <HTTPResponse> *)queryDumpStatus:(NSString *)id {
    NSMutableDictionary *status = [[self caches] objectForKey:id];
    if (status) {
        return [self ok:status];
    }
    return [self fail:@"任务不存在"];
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
        NSDictionary *json = @{
                @"bundle_id": bundle_id_value,
                @"name": name,
                @"version": version,
                @"executable": executable
        };
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
    } else if ([method isEqualToString:@"GET"] && [[url path] isEqualToString:@"/app/dump/status"]) {
        NSString *id;
        for (NSURLQueryItem *item in queryItems) {
            if ([[item name] isEqualToString:@"id"]) {
                id = item.value;
                break;
            }
        }
        if (!id) {
            return [self fail:@"缺少id参数"];
        }
        if ([id length] == 0) {
            return [self fail:@"id不能为空"];
        }
        return [self queryDumpStatus:id];
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
            return [self fail:[NSString stringWithFormat:@"请求参数非法{%@}JSON解析失败：%@", body_str, error]];
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
    } else if ([method isEqualToString:@"DELETE"] && [[url path] isEqualToString:@"/file/delete"]) {
        NSString *filePath;
        for (NSURLQueryItem *item in queryItems) {
            if ([[item name] isEqualToString:@"path"]) {
                filePath = item.value;
            }
        }
        if (!filePath) {
            return [self fail:@"缺少path参数"];
        }
        return [self fileDelete:filePath];
    } else if ([method isEqualToString:@"POST"] && [[url path] isEqualToString:@"/file/clear"]) {
        NSString *filePath = @"/var/mobile/Library/TrollDecrypt/decrypted";
        return [self folderClear:filePath];
    }

    return [self apis];
}

- (NSObject <HTTPResponse> *)apis {
    NSDictionary *data = @{
            @"/app/list": @{
                    @"method": @"get",
                    @"des": @"获取应用列表"
            },
            @"/app/info": @{
                    @"mthod": @"get",
                    @"des": @"查询app信息",
                    @"query": @{
                            @"bundle_id": @"应用标识"
                    }
            },
            @"/app/dump": @{
                    @"method": @"post",
                    @"des": @"砸壳",
                    @"json": @{
                            @"bundle_id": @"应用标识"
                    }
            },
            @"/app/dump/status": @{
                    @"method": @"get",
                    @"des": @"砸壳状态",
                    @"query": @{
                            @"id": @"砸壳任务标识"
                    }
            },
            @"/file/download": @{
                    @"method": @"get",
                    @"des": @"文件下载",
                    @"query": @{
                            @"path": @"文件绝对路径"
                    }
            },
            @"/file/delete": @{
                    @"method": @"delete",
                    @"des": @"文件删除",
                    @"query": @{
                            @"path": @"文件绝对路径"
                    }
            },
            @"/file/clear": @{
                    @"method": @"post",
                    @"des": @"砸壳文件夹清空"
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

@end
