//
//  MyHTTPConnection.m
//  TrollDecryptXcode
//
//  Created by lake on 2024/1/25.
//

#import "MyHTTPConnection.h"
#import "MyJsonResponse.h"
#import "TDUtils.h"
#import "server/DDNumber.h"
#import "server/HTTPAsyncFileResponse.h"
#import "server/HTTPDataResponse.h"
#import "server/HTTPFileResponse.h"
#import "server/HTTPMessage.h"
#import "server/HTTPRedirectResponse.h"
#import "server/HTTPResponse.h"
#import <Foundation/Foundation.h>

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    return YES;//支持所有方法
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)dumpAppMethod:(NSString *)bundle_id {
    
    if (!bundle_id || [bundle_id length]==0){
        return [self errorResponse:@"bundle_id 非法"];
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
        NSString *data_str = [NSString stringWithFormat:@"{\"bundle_id\":\"%@\",\"name\":\"%@\",\"version\":\"%@\",\"executable\":\"%@\"}", bundle_id_value, name, version, executable];

        NSData *response = [[NSString stringWithFormat:@"{\"ok\":true,\"data\":%@}", data_str] dataUsingEncoding:NSUTF8StringEncoding];
        MyJsonResponse *json = [[MyJsonResponse alloc] initWithData:response];
        return json;
    } else {
        return [self errorResponse:@"应用不在"];
    }
}
- (NSObject<HTTPResponse> *)fileDownload:(NSString *)filePath {
    HTTPAsyncFileResponse *response = [[HTTPAsyncFileResponse alloc] initWithFilePath:filePath forConnection:self];
    return response;
}
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)urlPath {

    NSURL *url = [NSURL URLWithString:urlPath];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;

    if ([method isEqualToString:@"POST"] && [[url path] isEqualToString:@"/dump/post"]) {
        NSString *bundle_id = nil;
        for (NSURLQueryItem *item in queryItems) {
            if ([[item name] isEqualToString:@"bundle_id"]) {
                bundle_id = item.value;
            }
        }
        if (!bundle_id) {
            return [self errorResponse:@"缺少bundle_id参数"];
        }
        return [self dumpAppMethod:bundle_id];
    } else if ([method isEqualToString:@"GET"] && [[url path] isEqualToString:@"/file/download"]) {
        NSString *filePath = nil;
        for (NSURLQueryItem *item in queryItems) {
            if ([[item name] isEqualToString:@"path"]) {
                filePath = item.value;
            }
        }
        if (!filePath) {
            return [self errorResponse:@"缺少path参数"];
        }
        return [self fileDownload:filePath];
    }

    return [self notFoundResponse];
}
- (NSObject<HTTPResponse> *)errorResponse:(NSString *)msg {
    NSData *response = [[NSString stringWithFormat:@"{\"ok\":false,\"msg\":\"%@\"}", msg] dataUsingEncoding:NSUTF8StringEncoding];
    MyJsonResponse *json = [[MyJsonResponse alloc] initWithData:response];
    return json;
}
- (NSObject<HTTPResponse> *)notFoundResponse {
    NSData *response = [@"{\"ok\":false,\"msg\":\"404\"}" dataUsingEncoding:NSUTF8StringEncoding];
    MyJsonResponse *json = [[MyJsonResponse alloc] initWithData:response];
    return json;
}

@end
