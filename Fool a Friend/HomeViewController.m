//
//  HomeViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "HomeViewController.h"
#import "HostViewController.h"
#import "JoinViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goHostAction:(id)sender {

    
    [self performExitAnimationWithCompletionBlock:^(BOOL finished) {
        HostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"hostViewController"];
        vc.delegate = self;
        [self presentViewController:vc animated:NO completion:nil];
    }];
}

- (IBAction)goJoinAction:(id)sender {
    [self performExitAnimationWithCompletionBlock:^(BOOL finished) {
        JoinViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"joinViewController"];
        vc.delegate = self;
        [self presentViewController:vc animated:NO completion:nil];
    }];
}

#pragma makr - HostViewDelegate Methods

-(void)hostViewController:(HostViewController *)controller didEndSessionWithReason:(QuitReason)reason
{
    if (reason == QuitReasonNoNetwork){
        [self showNoNetworkAlert];
    }
}
-(void)hostViewController:(HostViewController *)controller startGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients
{
    
}

-(void)hostViewControllerDidCancel:(HostViewController *)controller
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Animations
-(void) performExitAnimationWithCompletionBlock:(void (^)(BOOL))block{
    _buttonsEnabled = NO;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

                     }
                     completion:^(BOOL finished) {

                         [UIView animateWithDuration:1.0f
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{

                                          } completion:block];
                         [UIView animateWithDuration:0.3f
                                               delay:0.3f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{

                                          } completion:nil];
                     }];
    
}

#pragma mark - Alerts

-(void) showDisconnectedAlert{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Disconnected", @"Client Disconnected alert title")
                              message:NSLocalizedString(@"You were disconnected from the game.", @"Client disconnected alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    [alertView show];
}
-(void) showNoNetworkAlert{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"No Network", @"No network alert title")
                              message:NSLocalizedString(@"To use multiplayer, please enable Bluetooth or Wi-Fi in your device's Settings.", @"No network alert message")
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"Button: OK")
                              otherButtonTitles:nil];
    [alertView show];
}
@end
