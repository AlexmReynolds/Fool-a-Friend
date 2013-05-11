//
//  HostViewController.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchMakingServer.h"
@class HostViewController;

@protocol HostViewControllerDelegate <NSObject>

- (void) hostViewControllerDidCancel:(HostViewController *)controller;
-(void) hostViewController:(HostViewController *)controller didEndSessionWithReason:(QuitReason)reason;
-(void) hostViewController:(HostViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString*)name clients:(NSArray *)clients;

@end

@interface HostViewController : UIViewController<MatchmakingServerDelegate>{
    MatchMakingServer *_matchmakingServer;
    QuitReason _quitReason;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *centerLabel;

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (nonatomic, weak) id <HostViewControllerDelegate> delegate;

- (IBAction)exitAction:(id)sender;
- (IBAction)beginAction:(id)sender;

@end
