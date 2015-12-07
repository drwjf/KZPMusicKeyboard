//
//  KZPMusicKeyboardViewController.m
//  Schillinger
//
//  Created by Matt Rankin on 27/06/2014.
//  Copyright (c) 2014 Matt Rankin. All rights reserved.
//

#import "KZPMusicKeyboardViewController.h"
#import "UIView+frameOperations.h"
#import "KZPMusicKeyboardAudio.h"
#import "KZPMusicSciNotation.h"
#import "KZPMusicKeyboardMapViewController.h"
#import "KZPMusicKeyboardRibbonViewController.h"
#import "KZPMusicKeyboardDataAggregator.h"
#import "UIView+frameOperations.h"
#import "KZPMusicKeyboardSpellingViewController.h"


@interface KZPMusicKeyboardViewController () <KZPMusicKeyboardMapDelegate, KZPMusicKeyboardRibbonControlDelegate, KZPMusicKeyboardSpellingDelegate>

@property (weak, nonatomic) IBOutlet UIView *keyboardMainView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *keyButtons;

@property (weak, nonatomic) IBOutlet UIView *keyboardDefocusView;

@property (strong, nonatomic) KZPMusicKeyboardAudio *localAudio;
@property (strong, nonatomic) KZPMusicKeyboardRibbonViewController *controlRibbon;

@property (strong, nonatomic) KZPMusicKeyboardDataAggregator *musicDataAggregator;
@property (strong, nonatomic) KZPMusicKeyboardSpellingViewController *spellingSurfaceViewController;

@property (strong, nonatomic) KZPMusicKeyboardMapViewController *keyboardMapViewController;

@property (weak, nonatomic) id<KZPMusicKeyboardDelegate> musicalDelegate;

@end


@implementation KZPMusicKeyboardViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.musicDataAggregator = [[KZPMusicKeyboardDataAggregator alloc] init];

    [self loadLocalAudio];
    [self loadControlRibbon];
    [self loadKeyboardMap];
    [self loadSpellingSurface];
    [self setupKeyReleaseAction];
    [self setupDefocusView];
}

- (void)registerMusicDelegate:(id<KZPMusicKeyboardDelegate>)musicalDelegate controlDelegate:(id<KZPMusicKeyboardControlDelegate>)controlDelegate
{
    self.musicalDelegate = musicalDelegate;
    self.musicDataAggregator.musicalDelegate = musicalDelegate;
    self.controlRibbon.controlDelegate = controlDelegate;
}

- (void)loadLocalAudio
{
    self.localAudio = [[KZPMusicKeyboardAudio alloc] init];
    self.localAudio.patch = [self.controlRibbon selectedPatch];
}

- (void)loadKeyboardMap
{
    self.keyboardMapViewController = [[KZPMusicKeyboardMapViewController alloc] initWithNibName:@"KZPMusicKeyboardMapView" bundle:nil];
    self.keyboardMapViewController.delegate = self;
    [self.keyboardMapViewController.view setFrameY:self.controlRibbon.view.frame.size.height];
    [self.view addSubview:self.keyboardMapViewController.view];
}

- (void)loadControlRibbon
{
    self.controlRibbon = [[KZPMusicKeyboardRibbonViewController alloc] initWithNibName:@"KZPMusicKeyboardRibbonView" bundle:nil];
    self.controlRibbon.musicDataAggregator = self.musicDataAggregator;
    self.controlRibbon.delegate = self;
    [self.view addSubview:self.controlRibbon.view];
}

- (void)loadSpellingSurface
{
    self.spellingSurfaceViewController = [[KZPMusicKeyboardSpellingViewController alloc] init];
    self.spellingSurfaceViewController.musicDataAggregator = self.musicDataAggregator;
    self.spellingSurfaceViewController.delegate = self;
    NSMutableDictionary *keyButtonsByNoteID = [NSMutableDictionary dictionary];
    for (UIButton *key in self.keyButtons) {
        [keyButtonsByNoteID setObject:key forKey:[NSString stringWithFormat:@"%ld", (long)[key tag]]];
    }
    self.spellingSurfaceViewController.keyButtonsByNoteID = [NSDictionary dictionaryWithDictionary:keyButtonsByNoteID];
}


- (void)hideControlRibbon
{
    self.controlRibbon.view.hidden = YES;
    CGFloat controlRibbonHeight = self.controlRibbon.view.frame.size.height;
    [self.keyboardMainView setFrameY:self.keyboardMainView.frame.origin.y - controlRibbonHeight + 3];
    [self.keyboardMapViewController.view setFrameY:self.keyboardMapViewController.view.frame.origin.y - controlRibbonHeight + 3];
}

- (void)showControlRibbon
{
    self.controlRibbon.view.hidden = NO;
    CGFloat controlRibbonHeight = self.controlRibbon.view.frame.size.height;
    [self.keyboardMainView setFrameY:self.keyboardMainView.frame.origin.y + controlRibbonHeight - 3];
    [self.keyboardMapViewController.view setFrameY:self.keyboardMapViewController.view.frame.origin.y + controlRibbonHeight - 3];
}

- (CGFloat)height
{
    CGFloat controlRibbonHeight = self.controlRibbon.view.frame.size.height;
    CGFloat keyboardMapHeight = self.keyboardMapViewController.view.frame.size.height;
    CGFloat keyboardHeight = self.keyboardMainView.frame.size.height;
    return (self.controlRibbon.view.hidden ? 3 : controlRibbonHeight) + keyboardMapHeight + keyboardHeight;
}


#pragma mark - KZPMusicKeyboardMapDelegate -


- (void)updateKeyboardPosition:(float)relativePosition
{
    [self.keyboardMainView setFrameX:-( (self.keyboardMainView.frame.size.width - self.view.frame.size.width) * relativePosition )];
}


#pragma mark - KZPMusicKeyboardSpellingDelegate -


- (void)manualSpellingComplete
{
    [self.controlRibbon resetSpelling];
}


#pragma mark -


- (void)setKeyboardEnabled:(BOOL)keyboardEnabled
{
    if (keyboardEnabled) {
        self.keyboardDefocusView.hidden = YES;
        self.keyboardDefocusView.alpha = 0.0;
    } else {
        self.keyboardDefocusView.hidden = NO;
        self.keyboardDefocusView.alpha = 0.5;
        [self.controlRibbon resetSpelling];
    }
    _keyboardEnabled = keyboardEnabled;
}

- (void)setupDefocusView
{
    self.keyboardDefocusView.hidden = YES;
    self.keyboardDefocusView.alpha = 0.0;
    UITapGestureRecognizer *refocusGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refocusKeyboard)];
    [self.keyboardDefocusView addGestureRecognizer:refocusGesture];
}

- (void)recenter
{
    [self.keyboardMapViewController panToRangeWithCenterNote:60 animated:NO];
}

- (void)setupKeyReleaseAction
{
    for (UIButton *keyButton in self.keyButtons) {
        [keyButton addTarget:self action:@selector(keyButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
        [keyButton addTarget:self action:@selector(keyButtonReleased:) forControlEvents:UIControlEventTouchUpOutside];
    }
}


- (void)refocusKeyboard
{
    if (!self.keyboardEnabled) return;
    
    [self.musicDataAggregator reset];
    [self.controlRibbon resetDuration];
    [self.spellingSurfaceViewController dismissWithCompletion:^{
        self.keyboardDefocusView.hidden = YES;
    }];
}

- (IBAction)keyButtonPressed:(id)sender
{
    NSUInteger noteID = [sender tag];
    [self.localAudio noteOn:noteID];
    [self.controlRibbon sendDurationAndSpelling];
    [self.musicDataAggregator receivePitch:noteID];
    if ([self.musicalDelegate respondsToSelector:@selector(keyboardDidSendNoteOn:noteOff:)]) {
        [self.musicalDelegate keyboardDidSendNoteOn:@(noteID) noteOff:nil];
    }
}

- (IBAction)keyButtonReleased:(id)sender
{
    NSUInteger noteID = [sender tag];
    [self.localAudio noteOff:noteID];
    if ([self.musicalDelegate respondsToSelector:@selector(keyboardDidSendNoteOn:noteOff:)]) {
        [self.musicalDelegate keyboardDidSendNoteOn:nil noteOff:@(noteID)];
    }
}

@end
