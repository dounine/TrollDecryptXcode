#import <AVFAudio/AVAudioPlayer.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UnSleep.h"

//后台播放音频，避免后台失效
@implementation UnSleep

static AVAudioPlayer *audioPlayer;

//+ (void)load {//程序加载自动调用
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UnSleep *object = [UnSleep new];
//        [object setupAudioSession];
//        [object promptForInput];
//    });
//}
//
- (id)init {
    if (!(self = [super init]))
        return nil;

    [self setupAudioSession];
    return self;
}

- (void)promptForInput {
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入播放间隔" preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        UITextField *inputField = alert.textFields.firstObject;
        NSString *inputString = inputField.text;
        NSInteger interval = [inputString integerValue];
        [self startPreventSleep:interval];
    }];

    [alert addAction:okAction];
    [rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)startPreventSleep:(NSInteger)seconds {
    NSString *base64VoiceString = @"UklGRnAGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YUwGAACAgICAf4B/foB+f3+Afn9/gH9/f4B9gIB+f39/gH6Af39/f4B/f3+AfoB/fn+Af3+Af36AfoB/gH5/f4B+gH6Af36AgH99gH9/f39/gH9/f36Af35/f3+Af35/f4B/gH5+f39/f39/fn9/gH5/f4B/foCAf3+Af3+AgICBf39+gYB/gICBgX+AgIKAf4GBgX+AgIF/f4KBgYGCgYCAgYGBf4KBgIGCgIGBgoKBgICAgX6Bf4GBgoOBgoWCg4SIhoqWo7CqmntgOx8NGDtmmcTf27uKWzcqOWCYyOffxJ16Yl1nfpCJck8sHCZQkdn8/+OgVhgGHF+m4/LdnlcfDCllq+H03qlkMyA0YprCyriPY0VCVnaRoJmKeG50jKOyqY5oQjQ9ZZrI2s2kajkjLlWItcvDoXlbT1p3lKqlknhgWWR9l6epm4FlVVVid4+jpJ2Md2VcX2x+kJuZjn9wbHB7i5COhntycHiBiYyHfXRtbHJ6go6WlI+CcWVjbYKXpKGQd2NbYG+CjJGQiYaBfnx3dHR6hIyNjIN5cXB2fIaLjIuFfHZxcHN9ho6RjYR8cnJ2fYWJiIaBfXx9fIGBgoKChIOEhIODgoJ9end3eHyChYeHiYiGgXt0cG9ze4SLj5CMg314dnp/h4qKh395c3R3fISFiYeCfHl2en2FhomFgXx3eHx/hYiGhH16d3Z5fH+Cf314d3qBh4yLh4B5dXV4gYSIg312cnJ6hY6VlpGHfnVyc3h+g4WEgH58en+BhIeFhH98eHd3eH6CiIuKiIN6dXJ1e4WMj4uAdnFwdX+Kj5GMhHx2dnh8f4SBf3l0cnV7hpGVk4x+dnJyeoSMjYqAd3Nyd3uEio2MiYF9enh5e35+fH59gH+AgICAgX+BhYSDe3ZvbnV+i5WZlIp/d3NzeICGiIiEgH15en1/hYaFg315dnZ8f4WHhYOBfn9/f4GDgH96eXh7gIaKi4eBeW9vcnmCio+Oi4J6dnR2eX+FhoeFgXx5e3x/gYGBf359fH6CgoODgH16e32BhomJhH51cnF2fYaMj4mEenFvcHiAiI6PiIJ4c3J1fIOJi4uEfndydXl+h4qLhYB5dXV3foKGhYWAfHx6f4OGhoaBfHh3eX2DhYmGhX58enl5fH+CgoSCfn18fH5/goKBgYGCgYODg4KBfn17fICBg4SEfnx7eXt/f4SEg4ODf3x7enp+gYSGhYSBfXx5enx/gIKCgoF+fXt9foCDhYWDg39/fX19foCAgYCAgoGAf4F+fn5+f4B/gYB/gX+Af3+Af4GBgoCAf318f4CCg4OAfnp6en5/hIaFg4F+fHx+f4CDgoB/fX1/gYOBf316enyAhImIhYJ9e3h7fYCGhYN/fHl5fYCDhoWCgHx7fH+AgoSEgYB8fHt8fX+Cg4WDgoB+fXx6fX5/goCCgoGBgIKAf358fH1/goKDg4F+fXt9fYCDg4KAf3t7fH5/g4aEgoJ8fX2BgoSDgn16eXl8foKDhIGBf35/f4F/gX6Afn6AgIOCgYB9fHx9f4KEhIJ/fHt7f4CDhISAf3t7fH6CgoKBgH5/fYCBgYGBf359fX6AgIGCgoF/fn19fX+BgYKBgIF+fX1+fYGBgYGCgX59fX9+gYCBgn9/f36AgIKCg3+BfXx8fX99gIKCg4KBgH5+fX5+gYCCgYJ/f31/fn6AgYGCgYF/fn59gIGBg4GAfnx+f3+Bg4GCgH59fX5+f4GBgYOBgH9/fn6Af4KCf4B/fn9+gYCAgoB+fn58f3+Bg4GBf399gH+CgH+Afn19foCCgoKBf35+fH6BgISAgX5+fH+AgYCBgIB9f3x+f4CBgoGAgH9/fn+AgYB/gIB+fn+AgYGBgH+AfoB/f4CAf4GAgIB/fn9/gIKAgYCAgH5/gH9/f4GAf4CBgH9/f3+AgICBf4F/f31+gIB/gIKAgoB/fn5+gH6AgIKAgIB+gH9/gICAgX9/gH9/f3+AgYCAf4B+gH9/f4GBgYB/f39+fn+AgICAgIB/f39/f4CAgICAfoB/gX+AgH+Af3+AfoCAgIF/f39/f3+AgICBgH9+gH9/gYCAgH9/foCAfoF/gn+Af4B/f36AgICAgH9/gH5/f4F/gYF+f39/gH+AgIB/f3+Af4B/gYF/";
    NSData *audioData = [[NSData alloc] initWithBase64EncodedString:base64VoiceString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    if (error) {
        NSLog(@"Error creating audio player: %@", [error description]);
        return;
    } else {
        audioPlayer.volume = 0.0;
    }

    [audioPlayer prepareToPlay];

    NSTimer *preventSleepTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                          interval:seconds
                                                            target:self
                                                          selector:@selector(playMusic)
                                                          userInfo:nil
                                                           repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:preventSleepTimer
                                 forMode:NSDefaultRunLoopMode];
}

- (void)setupAudioSession {
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    // 启用混音选项，允许和其他应用同时播放音频
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    if (error) {
        NSLog(@"Error setting category options: %@", [error description]);
        return;
    }
    // 激活音频会话
    [audioSession setActive:YES error:&error];
    if (error) {
        NSLog(@"Error activating audio session: %@", [error description]);
        return;
    }
    // 在后台播放时，确保在 Info.plist 中设置了 "Required background modes" 为 "audio"。
}

- (void)playMusic {
    [audioPlayer play];
}

@end
