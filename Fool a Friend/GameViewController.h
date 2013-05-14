//
//  GameViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"
#import "VotingViewController.h"
#import "Game.h"
@class GameViewController;

@protocol GameViewControllerDelegate <NSObject>

-(void) gameViewController:(GameViewController *)controller didQuitWithReason:(QuitReason)reason;

@end
@interface GameViewController : UIViewController <UIAlertViewDelegate, GameDelegate, CardViewControllerDelegate,VotingViewControllerDelegate>{
    NSMutableDictionary *_nameLabels;
        AVAudioPlayer *_dealingCardsSound;
    CardViewController *_readerViewController;
    VotingViewController *_liarViewController;
}

@property (weak, nonatomic) IBOutlet UIView *cardContainer;
@property (nonatomic, weak) id <GameViewControllerDelegate> delegate;
@property (nonatomic, strong) Game *game;
@property (strong, nonatomic) IBOutlet UITextField *centerLabel;
- (IBAction)pickCardAction:(id)sender;

@end
