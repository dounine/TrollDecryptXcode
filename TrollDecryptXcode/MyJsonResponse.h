//
//  MyHTTPConnection.h
//  TrollDecryptXcode
//
//  Created by lake on 2024/1/25.
//
#import "server/HTTPResponse.h"
#import <Foundation/Foundation.h>

@interface MyJsonResponse : NSObject <HTTPResponse> {
    NSUInteger offset;
    NSData *data;
    NSMutableDictionary *headers;
}


- (id)initWithData:(NSData *)data;

- (id)setHeader:(NSString *)name value:(NSString *)valueParam;

@end
