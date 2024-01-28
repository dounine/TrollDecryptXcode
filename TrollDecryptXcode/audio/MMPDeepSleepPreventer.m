#pragma mark -
#pragma mark Imports

#import "MMPDeepSleepPreventer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


#pragma mark -
#pragma mark MMPDeepSleepPreventer Private Interface

@interface MMPDeepSleepPreventer ()

- (void)mmp_playPreventSleepSound;

- (void)mmp_setUpAudioSession;

@end


@implementation MMPDeepSleepPreventer


#pragma mark -
#pragma mark Synthesizes

@synthesize audioPlayer = audioPlayer_;
@synthesize preventSleepTimer = preventSleepTimer_;


#pragma mark -
#pragma mark Creation and Destruction

- (id)init {
    if (!(self = [super init]))
        return nil;

    [self mmp_setUpAudioSession];

    // Set up path to sound file
//    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"MMPSilence"
//                                                              ofType:@"wav"];//可加载声音文件

//    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];

    //wav文件的base64编码开头格式
//    NSString *wavBeginBaseCode = @"UklGRpQbAABXQVZFZm10IBAAAAABAAEAQB8AAIA+AAACABAARkxMUswPA";
//    NSMutableString *repeatVoice = [NSMutableString stringWithString:wavBeginBaseCode];
//    NSString *emptyVoice = @"A";
//    //循环添加空声音
//    for (int i = 0; i < 8999; i++) {
//        [repeatVoice appendString:emptyVoice];
//        if (i % 3000 == 0) {
//            [repeatVoice appendString:@"BkYXRhnAs"];//无声音频
//        }
//    }
    NSString *base64VoiceString = @"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";
    NSData *voiceData = [[NSData alloc] initWithBase64EncodedString:base64VoiceString options:NSDataBase64DecodingIgnoreUnknownCharacters];

    // Set up audio player with sound file
//    audioPlayer_ = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
//                                                          error:nil];
    audioPlayer_ = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];

    [self.audioPlayer prepareToPlay];

    // You may want to set this to 0.0 even if your sound file is silent.
    // I don't know exactly, if this affects battery life, but it can't hurt.
    [self.audioPlayer setVolume:1.0];

    return self;
}


#pragma mark -
#pragma mark Public Methods

- (void)startPreventSleep {
    // We need to play a sound at least every 10 seconds to keep the iPhone awake.
    // It doesn't seem to affect battery life how often inbetween these 10 seconds the sound file is played.
    // To prevent the iPhone from falling asleep due to timing/performance issues, we play a sound file every five seconds.

    // We create a new repeating timer, that begins firing immediately and then every five seconds afterwards.
    // Every time it fires, it calls -mmp_playPreventSleepSound.
    NSTimer *preventSleepTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                          interval:3.0
                                                            target:self
                                                          selector:@selector(mmp_playPreventSleepSound)
                                                          userInfo:nil
                                                           repeats:YES];
    self.preventSleepTimer = preventSleepTimer;

    // Add the timer to the current run loop.
    [[NSRunLoop currentRunLoop] addTimer:self.preventSleepTimer
                                 forMode:NSDefaultRunLoopMode];
}


- (void)stopPreventSleep {
    [self.preventSleepTimer invalidate];
    self.preventSleepTimer = nil;
}


#pragma mark -
#pragma mark Private Methods

- (void)mmp_playPreventSleepSound {
    [self.audioPlayer play];
}


- (void)mmp_setUpAudioSession {
    // Initialize audio session
    AudioSessionInitialize
            (
                    NULL, // Use NULL to use the default (main) run loop.
                    NULL, // Use NULL to use the default run loop mode.
                    NULL, // A reference to your interruption listener callback function.
                    // See “Responding to Audio Session Interruptions” in Apple's "Audio Session Programming Guide" for a description of how to write
                    // and use an interruption callback function.
                    NULL  // Data you intend to be passed to your interruption listener callback function when the audio session object invokes it.
            );

    // Activate audio session
    OSStatus activationResult = 0;
    activationResult = AudioSessionSetActive(true);

    if (activationResult) {
        MMPDLog(@"AudioSession is active");
    }

    // Set up audio session category to kAudioSessionCategory_MediaPlayback.
    // While playing sounds using this session category at least every 10 seconds, the iPhone doesn't go to sleep.
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback; // Defines a new variable of type UInt32 and initializes it with the identifier
    // for the category you want to apply to the audio session.
    AudioSessionSetProperty
            (
                    kAudioSessionProperty_AudioCategory, // The identifier, or key, for the audio session property you want to set.
                    sizeof(sessionCategory),             // The size, in bytes, of the property value that you are applying.
                    &sessionCategory                     // The category you want to apply to the audio session.
            );

    // Set up audio session playback mixing behavior.
    // kAudioSessionCategory_MediaPlayback usually prevents playback mixing, so we allow it here. This way, we don't get in the way of other sound playback in an application.
    // This property has a value of false (0) by default. When the audio session category changes, such as during an interruption, the value of this property reverts to false.
    // To regain mixing behavior you must then set this property again.

    // Always check to see if setting this property succeeds or fails, and react appropriately; behavior may change in future releases of iPhone OS.
    OSStatus propertySetError = 0;
    UInt32 allowMixing = true;

    propertySetError = AudioSessionSetProperty
            (
                    kAudioSessionProperty_OverrideCategoryMixWithOthers, // The identifier, or key, for the audio session property you want to set.
                    sizeof(allowMixing),                                 // The size, in bytes, of the property value that you are applying.
                    &allowMixing                                         // The value to apply to the property.
            );

    if (propertySetError) {
        MMPALog(@"Error setting kAudioSessionProperty_OverrideCategoryMixWithOthers: %d", propertySetError);
    }
}

@end
