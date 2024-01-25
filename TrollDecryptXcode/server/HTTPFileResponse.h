#import "HTTPResponse.h"
#import <Foundation/Foundation.h>

@class HTTPConnection;

@interface HTTPFileResponse : NSObject <HTTPResponse> {
    HTTPConnection *connection;

    NSString *filePath;
    UInt64 fileLength;
    UInt64 fileOffset;

    BOOL aborted;

    int fileFD;
    void *buffer;
    NSUInteger bufferSize;
    NSMutableDictionary *headers;
}

- (id)initWithFilePath:(NSString *)filePath forConnection:(HTTPConnection *)connection;
- (NSString *)filePath;

@end
