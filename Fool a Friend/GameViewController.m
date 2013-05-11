//
//  GameViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

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


#pragma mark - GameDelegate

-(void)game:(Game*)game didQuitWithReason:(QuitReason)reason
{
    [self.delegate gameViewController:self didQuitWithReason:reason];
}

-(void)gameWaitingForServerReady:(Game *)game{
    self.centerLabel.text = NSLocalizedString(@"Waiting for game to start...", @"Status text: waiting for server");
}

-(void)gameWaitingForClientsReady:(Game *)game{
    self.centerLabel.text = NSLocalizedString(@"Waiting for other players...", @"Status text: waiting for clients");
}
- (void)viewDidUnload {
    [self setCenterLabel:nil];
    [super viewDidUnload];
}
@end
