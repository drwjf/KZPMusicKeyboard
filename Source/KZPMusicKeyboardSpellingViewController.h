//
//  KZPMusicKeyboardSpellingViewController.h
//  KZPMusicKeyboard
//
//  Created by Matthew Rankin on 6/12/2015.
//  Copyright © 2015 Sudoseng. All rights reserved.
//

#import "ViewController.h"
#import "KZPMusicKeyboardDelegate.h"

@interface KZPMusicKeyboardSpellingViewController : ViewController

@property (weak, nonatomic) id<KZPMusicKeyboardDelegate> delegate;

@property (weak, nonatomic) UIView *spellingSurface;

@end