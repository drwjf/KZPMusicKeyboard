//
//  KZPMusicKeyboardDelegate.h
//  KZPMusicKeyboard
//
//  Created by Matthew Rankin on 6/12/2015.
//  Copyright © 2015 Sudoseng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZPMusicPitchData.h"
#import "KZPMusicDurationData.h"
#import "KZPMusicKeyboardDelegate.h"


@protocol KZPMusicKeyboardDataDelegate <NSObject>

@optional

//
// Implement to receive processed note data. This may not arrive in the same instant
// as the key presses if chord detection is enabled.
//
- (void)keyboardDidSendPitchData:(KZPMusicPitchData *)pitchData
                withDurationData:(KZPMusicDurationData *)durationData;

//
// Implement to receive raw playing data. This is sent immediately on key press/release.
//
- (void)keyboardDidSendNoteOn:(NSNumber *)noteOnPitch noteOff:(NSNumber *)noteOffPitch;

@end


@protocol KZPMusicKeyboardControlDelegate <NSObject>

@optional

//
// Implement to receive miscellaneous control signals.
//
- (void)keyboardWasDismissed;
- (void)keyboardDidSendBackspace;

@end


@protocol KZPMusicKeyboardDelegate <KZPMusicKeyboardControlDelegate, KZPMusicKeyboardDataDelegate>
@end
