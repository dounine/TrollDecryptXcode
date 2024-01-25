//
//  MyHTTPConnection.m
//  TrollDecryptXcode
//
//  Created by lake on 2024/1/25.
//

#import "MyHTTPConnection.h"
#import "server/DDNumber.h"
#import "server/HTTPDataResponse.h"
#import "server/HTTPMessage.h"
#import "server/HTTPRedirectResponse.h"
#import "server/HTTPResponse.h"
#import "MyJsonResponse.h"
#import <Foundation/Foundation.h>

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"]) {
        return YES;
    }
    return NO;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {

    NSData *response = [@"{\"ok\":true}" dataUsingEncoding:NSUTF8StringEncoding];
    
    MyJsonResponse *rr = [[MyJsonResponse alloc] initWithData:response];
    
    return rr;
}

@end
