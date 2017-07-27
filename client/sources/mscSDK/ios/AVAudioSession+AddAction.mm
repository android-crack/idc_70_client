#import "AVAudioSession+AddAction.h"

@implementation AVAudioSession (AddAction)

- (BOOL)setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError * _Nullable __autoreleasing *)outError {
    return YES;
}

@end
