#pragma mark -
#pragma mark MMPLog

#ifndef MMPDLog
    #ifdef DEBUG
        #define MMPDLog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    #else
        #define MMPDLog(...) do { } while (0)
    #endif
#endif

#ifndef MMPALog
    #define MMPALog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif


#pragma mark -
#pragma mark Imports and Forward Declarations

#import <Foundation/Foundation.h>

@class AVAudioPlayer;


#pragma mark -
#pragma mark Public Interface

@interface MMPDeepSleepPreventer : NSObject

#pragma mark -
#pragma mark Properties

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer       *preventSleepTimer;


#pragma mark -
#pragma mark Public Methods

- (void)startPreventSleep;
- (void)stopPreventSleep;

@end
