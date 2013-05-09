//
//  JoinViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchMakingClient.h"
@class JoinViewController;

@protocol JoinViewControllerDelegate <NSObject>

-(void) joinViewControllerDidCancel:(JoinViewController *)controller;
-(void) joinViewController:(JoinViewController *)controller didDisconnectWithReason:(QuitReason)reason;
-(void) joinViewController:(JoinViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;

@end
@interface JoinViewController : UIViewController<MatchmakingClientDelegate>


@property (nonatomic, weak) id <JoinViewControllerDelegate> delegate;


@end
