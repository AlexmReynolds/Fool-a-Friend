//
//  GameViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
@class GameViewController;

@protocol GameViewControllerDelegate <NSObject>

-(void) gameViewController:(GameViewController *)controller didQuitWithReason:(QuitReason)reason;

@end
@interface GameViewController : UIViewController <UIAlertViewDelegate, GameDelegate>{
    NSMutableDictionary *_nameLabels;
        AVAudioPlayer *_dealingCardsSound;
}

@property (nonatomic, weak) id <GameViewControllerDelegate> delegate;
@property (nonatomic, strong) Game *game;
@property (strong, nonatomic) IBOutlet UITextField *centerLabel;

@end
