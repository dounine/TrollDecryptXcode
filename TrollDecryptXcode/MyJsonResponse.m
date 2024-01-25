
#import "MyJsonResponse.h"
#import <Foundation/Foundation.h>

@implementation MyJsonResponse

- (id)initWithData:(NSData *)dataParam {
    if ((self = [super init])) {
        offset = 0;
        data = dataParam;
        headers = [NSMutableDictionary dictionary];
        
        headers[@"Content-Type"] = @"application/json;charset=utf-8";
    }
    return self;
}

- (UInt64)contentLength {
    return (UInt64)[data length];
}

- (BOOL)isDone {
    return (offset == [data length]);
}

- (NSDictionary *)httpHeaders {
    return headers;
}

- (id)setHeader:(NSString *)name value:(NSString *)valueParam{
    headers[name] = valueParam;
    return self;
}

- (UInt64)offset {
    return offset;
}

- (NSData *)readDataOfLength:(NSUInteger)lengthParameter {
    NSUInteger remaining = [data length] - offset;
    NSUInteger length = lengthParameter < remaining ? lengthParameter : remaining;

    void *bytes = (void *) ([data bytes] + offset);

    offset += length;

    return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:NO];
}

- (void)setOffset:(UInt64)offsetParam {
    offset = (NSUInteger) offsetParam;
}

@end
